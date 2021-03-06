defmodule VknobFw.MixProject do
  use Mix.Project

  @app :vknob_fw
  @version "1.0.0"
  @all_targets [:rpi, :rpi0, :rpi2, :rpi3, :rpi3a, :rpi4, :bbb, :x86_64]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.9",
      archives: [nerves_bootstrap: "~> 1.8"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {VknobFw.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Dependencies for all targets
      {:nerves, "~> 1.6.0", runtime: false, targets: @all_targets},
      {:shoehorn, "~> 0.6"},
      {:ring_logger, "~> 0.6"},
      {:toolshed, "~> 0.2"},
      {:sweet_xml, "~> 0.6"},
      {:volume_knob, path: "../volume_knob"},
      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.6"},
      {:nerves_pack, "~> 0.3"},
      {:vintage_net_wizard, "~> 0.2"},
      # {:vintage_net_wizard, git: "https://github.com/nerves-networking/vintage_net_wizard.git"},

      # Dependencies for specific targets
      {:nerves_system_rpi, "~> 1.12", runtime: false, targets: :rpi},
      {:nerves_system_rpi0, "~> 1.12", runtime: false, targets: :rpi0},
      {:nerves_system_rpi2, "~> 1.12", runtime: false, targets: :rpi2},
      {:nerves_system_rpi3, "~> 1.12", runtime: false, targets: :rpi3},
      {:nerves_system_rpi3a, "~> 1.12", runtime: false, targets: :rpi3a},
      {:nerves_system_rpi4, "~> 1.12", runtime: false, targets: :rpi4},
      {:nerves_system_bbb, "~> 2.7", runtime: false, targets: :bbb},
      {:nerves_system_x86_64, "~> 1.12", runtime: false, targets: :x86_64}
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod
    ]
  end
end
