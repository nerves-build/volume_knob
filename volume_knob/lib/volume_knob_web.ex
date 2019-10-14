defmodule VolumeKnobWeb do
  def controller do
    quote do
      use Phoenix.Controller, namespace: VolumeKnobWeb

      import Plug.Conn
      import VolumeKnobWeb.Gettext
      import Phoenix.LiveView.Controller
      alias VolumeKnobWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/volume_knob_web/templates",
        namespace: VolumeKnobWeb

      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      use Phoenix.HTML

      import VolumeKnobWeb.ErrorHelpers
      import VolumeKnobWeb.Gettext

      import Phoenix.LiveView,
        only: [live_render: 2, live_render: 3, live_link: 1, live_link: 2]

      alias VolumeKnobWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import VolumeKnobWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
