defmodule Phoenix.LiveView.View do
  @moduledoc false

  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  # Token version. Should be changed whenever new data is stored.
  @token_vsn 1

  # Max session age in seconds. Equivalent to 2 weeks.
  @max_session_age 1_209_600

  # Total length of 8 bytes when 64 encoded
  @rand_bytes 6

  # All available mount options
  @mount_opts [:temporary_assigns]

  @doc """
  Acts as a view via put_view to maintain the
  controller render + instrumentation stack.
  """
  def render("template.html", %{content: content}) do
    content
  end
  def render(_other, _assigns), do: nil

  @doc """
  Defines the value for the `__live__` callback.
  """
  def live_definition(module, kind, opts) do
    container = opts[:container] || {:div, []}
    namespace = opts[:namespace] || module |> Module.split() |> Enum.take(1) |> Module.concat()
    name = module |> Atom.to_string() |> String.replace_prefix("#{namespace}.", "")
    %{container: container, name: name, kind: kind}
  end

  @doc """
  Clears the changes from the socket assigns.
  """
  def clear_changed(%Socket{private: %{temporary_assigns: temporary}, assigns: assigns} = socket) do
    %Socket{socket | changed: %{}, assigns: Map.merge(assigns, temporary)}
  end

  @doc """
  Checks if the socket changed.
  """
  def changed?(%Socket{changed: changed}), do: changed != %{}

  @doc """
  Returns the socket's flash messages.
  """
  def get_flash(%Socket{private: private}) do
    private[:flash]
  end

  @doc """
  Returns true if the socket is connected.
  """
  def connected?(%Socket{connected?: connected?}), do: connected?

  @doc """
  Returns the connect params.
  """
  def get_connect_params(%Socket{} = socket) do
    cond do
      child?(socket) ->
        raise RuntimeError, """
        attempted to read connect_params from a nested child LiveView #{inspect(socket.view)}.

        Only the root LiveView has access to connect params.
        """

      connect_params = socket.private[:connect_params] ->
        if connected?(socket), do: connect_params, else: nil

      true ->
        raise RuntimeError, """
        attempted to read connect_params outside of #{inspect(socket.view)}.mount/2.

        connect_params only exist while mounting. If you require access to this information
        after mount, store the state in socket assigns.
        """
    end
  end

  @doc """
  Configures the socket for use.
  """
  def configure_socket(%{id: nil} = socket, private) do
    configure_socket(%{socket | id: random_id()}, private)
  end

  def configure_socket(socket, private) do
    private =
      private
      |> Map.put(:temporary_assigns, %{})
      |> Map.put_new(:connect_params, %{})

    %{socket | private: private}
  end

  @doc """
  Prunes any data no longer needed after mount.
  """
  def post_mount_prune(%Socket{} = socket) do
    socket
    |> clear_changed()
    |> drop_private([:connect_params, :assigned_new])
  end

  @doc """
  Annotates the socket for redirect.
  """
  def put_redirect(%Socket{redirected: nil} = socket, :redirect, %{to: _} = opts) do
    %Socket{socket | redirected: {:redirect, opts}}
  end

  def put_redirect(%Socket{redirected: nil} = socket, :live, %{to: _, kind: kind} = opts)
      when kind in [:push, :replace] do
    if child?(socket) do
      raise ArgumentError, """
      attempted to live_redirect from a nested child socket.

      Only the root parent LiveView can issue live redirects.
      """
    else
      %Socket{socket | redirected: {:live, opts}}
    end
  end

  def put_redirect(%Socket{redirected: to} = _socket, _kind, _opts) do
    raise ArgumentError, "socket already prepared to redirect with #{inspect(to)}"
  end

  def drop_redirect(%Socket{} = socket) do
    %Socket{socket | redirected: nil}
  end

  defp load_child_id!(opts) do
    child_id =
      opts[:id] ||
        raise ArgumentError,
              "an :id is required when rendering child LiveView/LiveComponent. " <>
                "The :id must uniquely identify the child."

    to_string(child_id)
  end

  @doc """
  Renders the view into a `%Phoenix.LiveView.Rendered{}` struct.
  """
  def dynamic_render(%Socket{} = socket, view) do
    to_rendered(socket, view)
  end

  defp strip_for_render(%Socket{} = socket) do
    if connected?(socket) do
      %Socket{socket | assigns: %{}}
    else
      socket
    end
  end

  @doc """
  Verifies the session token.

  Returns the decoded map of session data or an error.

  ## Examples

      iex> verify_session(AppWeb.Endpoint, encoded_token, static_token)
      {:ok, %{} = decoded_session}

      iex> verify_session(AppWeb.Endpoint, "bad token", "bac static")
      {:error, :invalid}

      iex> verify_session(AppWeb.Endpoint, "expired", "expired static")
      {:error, :expired}
  """
  def verify_session(endpoint, session_token, static_token) do
    with {:ok, session} <- verify_token(endpoint, session_token),
         {:ok, static} <- verify_static_token(endpoint, static_token) do
      {:ok, Map.merge(session, static)}
    end
  end

  defp verify_static_token(_endpoint, nil), do: {:ok, %{assigned_new: []}}
  defp verify_static_token(endpoint, token), do: verify_token(endpoint, token)

  defp verify_token(endpoint, token) do
    case Phoenix.Token.verify(endpoint, salt!(endpoint), token, max_age: @max_session_age) do
      {:ok, {@token_vsn, term}} -> {:ok, term}
      {:ok, _} -> {:error, :outdated}
      {:error, _} = error -> error
    end
  end

  @doc """
  Signs the socket's flash into a token if it has been set.
  """
  def sign_flash(%Socket{}, nil), do: nil

  def sign_flash(%Socket{endpoint: endpoint}, %{} = flash) do
    LiveView.Flash.sign_token(endpoint, salt!(endpoint), flash)
  end

  @doc """
  Returns the configured signing salt for the endpoint.
  """
  def salt!(endpoint) when is_atom(endpoint) do
    endpoint.config(:live_view)[:signing_salt] ||
      raise ArgumentError, """
      no signing salt found for #{inspect(endpoint)}.

      Add the following LiveView configuration to your config/config.exs:

          config :my_app, MyAppWeb.Endpoint,
              ...,
              live_view: [signing_salt: "#{random_encoded_bytes()}"]

      """
  end

  @doc """
  Returns the internal or external matched LiveView route info for the given uri
  """
  def live_link_info!(nil, view, _uri) do
    raise ArgumentError,
          "cannot invoke handle_params/3 on #{inspect(view)} " <>
            "because it is not mounted nor accessed through the router live/3 macro"
  end

  def live_link_info!(router, view, uri) do
    %URI{host: host, path: path, query: query} = URI.parse(uri)
    query_params = if query, do: Plug.Conn.Query.decode(query), else: %{}

    case Phoenix.Router.route_info(router, "GET", path, host) do
      %{plug: Phoenix.LiveView.Plug, plug_opts: ^view, path_params: path_params} ->
        {:internal, Map.merge(query_params, path_params)}

      %{} ->
        :external

      :error ->
        raise ArgumentError,
              "cannot invoke handle_params nor live_redirect/live_link to #{inspect(uri)} " <>
                "because it isn't defined in #{inspect(router)}"
    end
  end

  @doc """
  Raises error message for bad live redirect.
  """
  def raise_bad_stop_and_live_redirect!() do
    raise RuntimeError, """
    attempted to live redirect while stopping.

    a LiveView cannot be stopped while issuing a live redirect to the client. \
    Use redirect/2 instead if you wish to stop and redirect.
    """
  end

  @doc """
  Raises error message for bad stop with no redirect.
  """
  def raise_bad_stop_and_no_redirect!() do
    raise RuntimeError, """
    attempted to stop socket without redirecting.

    you must always redirect when stopping a socket, see redirect/2.
    """
  end

  @doc """
  Renders a live view without spawning a LiveView server.

    * `conn` - the Plug.Conn struct form the HTTP request
    * `view` - the LiveView module

  ## Options

    * `:router` - the router the live view was built at
    * `:session` - the required map of session data
    * `:container` - the optional tuple for the HTML tag and DOM attributes to
      be used for the LiveView container. For example: `{:li, style: "color: blue;"}`
  """
  def static_render(%Plug.Conn{} = conn, view, opts) do
    session = Keyword.get(opts, :session, %{})
    config = load_live!(view, :view)
    {tag, extended_attrs} = container(config, opts)
    router = Keyword.get(opts, :router)
    endpoint = Phoenix.Controller.endpoint_module(conn)
    request_url = Plug.Conn.request_url(conn)

    socket =
      configure_socket(
        %Socket{endpoint: endpoint, view: view},
        %{assigned_new: {conn.assigns, []}}
      )

    case call_mount_and_handle_params!(socket, router, view, session, conn.params, request_url) do
      {:ok, socket} ->
        attrs = [
          {:id, socket.id},
          {:data,
           phx_view: config.name,
           phx_session: sign_root_session(socket, router, view, session)}
          | extended_attrs
        ]

        html = Phoenix.HTML.Tag.content_tag(tag, to_rendered(socket, view), attrs)
        {:ok, html}

      {:stop, reason} ->
        {:stop, reason}
    end
  end

  @doc """
  Renders only the static container of the Liveview.

  Accepts same options as `static_render/3`.

  This is called by external live links.
  """
  def static_container_render(%Plug.Conn{} = conn, view, opts) do
    session = Keyword.get(opts, :session, %{})
    config = load_live!(view, :view)
    {tag, extended_attrs} = container(config, opts)
    router = Keyword.get(opts, :router)
    endpoint = Phoenix.Controller.endpoint_module(conn)

    socket =
      configure_socket(
        %Socket{endpoint: endpoint, view: view},
        %{assigned_new: {conn.assigns, []}}
      )

    session_token = sign_root_session(socket, router, view, session)

    attrs = [
      {:id, socket.id},
      {:data, phx_view: config.name, phx_session: session_token}
      | extended_attrs
    ]

    tag
    |> Phoenix.HTML.Tag.content_tag(attrs, do: nil)
    |> Phoenix.HTML.safe_to_string()
  end

  @doc """
  Renders a nested live view without spawning a server.

    * `parent` - the parent `%Phoenix.LiveView.Socket{}`
    * `view` - the child LiveView module

  Accepts the same options as `static_render/3`.
  """
  def nested_static_render(%Socket{endpoint: endpoint} = parent, view, opts) do
    session = Keyword.get(opts, :session, %{})
    config = load_live!(view, :view)
    container = container(config, opts)
    child_id = load_child_id!(opts)

    socket =
      configure_socket(
        %Socket{
          id: child_id,
          endpoint: endpoint,
          root_pid: parent.root_pid,
          parent_pid: self()
        },
        %{assigned_new: {parent.assigns, []}}
      )

    if connected?(parent) do
      connected_nested_static_render(parent, config, socket, view, session, container)
    else
      disconnected_nested_static_render(parent, config, socket, view, session, container)
    end
  end

  @doc "Returns a random ID with valid DOM tokens"
  def random_id do
    "phx-"
    |> Kernel.<>(random_encoded_bytes())
    |> String.replace(["/", "+"], "-")
  end

  defp disconnected_nested_static_render(parent, config, socket, view, session, container) do
    {tag, extended_attrs} = container
    socket = call_mount!(socket, view, session)

    if exports_handle_params?(view) do
      raise ArgumentError, "handle_params/3 is not allowed on child LiveViews, only at the root"
    end

    attrs = [
      {:id, socket.id},
      {:data,
       phx_view: config.name,
       phx_session: "",
       phx_static: sign_static_token(socket),
       phx_parent_id: parent.id}
      | extended_attrs
    ]

    Phoenix.HTML.Tag.content_tag(tag, to_rendered(socket, view), attrs)
  end

  defp connected_nested_static_render(parent, config, socket, view, session, container) do
    {tag, extended_attrs} = container
    session_token = sign_nested_session(parent, socket, view, session)

    attrs = [
      {:id, socket.id},
      {:data,
       phx_parent_id: parent.id, phx_view: config.name, phx_session: session_token, phx_static: ""}
      | extended_attrs
    ]

    Phoenix.HTML.Tag.content_tag(tag, "", attrs)
  end

  defp call_mount_and_handle_params!(socket, router, view, session, params, uri) do
    socket
    |> call_mount!(view, session)
    |> mount_handle_params(router, view, params, uri)
    |> case do
      {:noreply, %Socket{redirected: nil} = new_socket} ->
        {:ok, new_socket}

      {:noreply, %Socket{redirected: redirected}} ->
        {:stop, redirected}

      {:stop, %Socket{redirected: nil}} ->
        raise_bad_stop_and_no_redirect!()

      {:stop, %Socket{redirected: {:live, _}}} ->
        raise_bad_stop_and_live_redirect!()

      {:stop, %Socket{redirected: redirected}} ->
        {:stop, redirected}
    end
  end

  defp mount_handle_params(socket, router, view, params, uri) do
    cond do
      not exports_handle_params?(view) ->
        {:noreply, socket}

      router == nil ->
        live_link_info!(router, view, uri)

      true ->
        view.handle_params(params, uri, socket)
    end
  end

  defp exports_handle_params?(view), do: function_exported?(view, :handle_params, 3)

  @doc """
  Calls the view's `mount/2` callback while handling possible options.
  """
  def call_mount!(%Socket{} = socket, view, session) do
    socket =
      case view.mount(session, socket) do
        {:ok, %Socket{} = socket, opts} when is_list(opts) ->
          Enum.reduce(opts, socket, fn {key, val}, acc -> mount_opt(acc, key, val) end)

        {:ok, %Socket{} = socket} ->
          socket

        other ->
          raise ArgumentError, """
          invalid result returned from #{inspect(view)}.mount/2.

          Expected {:ok, socket} | {:ok, socket, opts}, got: #{inspect(other)}
          """
      end

    if socket.redirected do
      raise "cannot redirect socket on mount/2"
    end

    socket
  end

  defp sign_root_session(%Socket{id: id, endpoint: endpoint}, router, view, session) do
    # IMPORTANT: If you change the third argument, @token_vsn has to be bumped.
    sign_token(endpoint, salt!(endpoint), %{
      id: id,
      view: view,
      router: router,
      parent_pid: nil,
      root_pid: nil,
      session: session
    })
  end

  defp sign_nested_session(%Socket{} = parent, %Socket{} = child, view, session) do
    # IMPORTANT: If you change the third argument, @token_vsn has to be bumped.
    sign_token(parent.endpoint, salt!(parent.endpoint), %{
      id: child.id,
      view: view,
      parent_pid: self(),
      root_pid: parent.root_pid,
      session: session
    })
  end

  defp sign_static_token(%Socket{id: id, endpoint: endpoint} = socket) do
    # IMPORTANT: If you change the third argument, @token_vsn has to be bumped.
    sign_token(endpoint, salt!(endpoint), %{
      id: id,
      assigned_new: assigned_new_keys(socket)
    })
  end

  defp random_encoded_bytes do
    @rand_bytes
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
  end

  defp sign_token(endpoint_mod, salt, data) do
    Phoenix.Token.sign(endpoint_mod, salt, {@token_vsn, data})
  end

  defp assigned_new_keys(socket) do
    {_, keys} = socket.private.assigned_new
    keys
  end

  defp child?(%Socket{parent_pid: pid}), do: is_pid(pid)

  defp load_live!(view, kind) do
    case view.__live__() do
      %{kind: ^kind} = config ->
        config

      %{kind: kind} ->
        raise "Expected #{inspect view} to be a #{kind}, but it is a #{kind}"
    end
  end

  defp container(%{container: {tag, attrs}}, opts) do
    case opts[:container] do
      {tag, extra} -> {tag, Keyword.merge(attrs, extra)}
      nil -> {tag, attrs}
    end
  end

  defp mount_opt(%Socket{} = socket, key, val) when key in @mount_opts do
    do_mount_opt(socket, key, val)
  end

  defp mount_opt(%Socket{view: view}, key, val) do
    raise ArgumentError, """
    invalid option returned from #{inspect(view)}.mount/2.

    Expected keys to be one of #{inspect(@mount_opts)}
    got: #{inspect(key)}: #{inspect(val)}
    """
  end

  defp do_mount_opt(socket, :temporary_assigns, keys) when is_list(keys) do
    temp_assigns = for(key <- keys, into: %{}, do: {key, nil})
    %Socket{socket | assigns: Map.merge(temp_assigns, socket.assigns),
                     private: Map.put(socket.private, :temporary_assigns, temp_assigns)}
  end

  defp drop_private(%Socket{private: private} = socket, keys) do
    %Socket{socket | private: Map.drop(private, keys)}
  end

  defp to_rendered(socket ,view) do
    assigns = Map.put(socket.assigns, :socket, strip_for_render(socket))

    case view.render(assigns) do
      %Phoenix.LiveView.Rendered{} = rendered ->
        rendered

      other ->
        raise RuntimeError, """
        expected #{inspect(view)}.render/1 to return a %Phoenix.LiveView.Rendered{} struct

        Ensure your render function uses ~L, or your eex template uses the .leex extension.

        Got:

            #{inspect(other)}

        """
    end
  end
end
