defmodule ElixirEvents.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_events,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ElixirEvents.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:phoenix, "~> 1.8.0"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.1.0"},
      {:lazy_html, ">= 0.0.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:ecto_psql_extras, "~> 0.6"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.5"},
      {:tz, "~> 0.28.1"},
      {:tz_extra, "~> 0.45"},
      {:sentry, "~> 11.0.1"},
      {:hackney, "~> 1.8"},
      {:ex_hash_ring, "~> 7.0"},
      {:req, "~> 0.5.7"},
      {:slugify, "~> 1.3"},
      {:fun_with_flags, "~> 1.13.0"},
      {:fun_with_flags_ui, "~> 1.0"},
      {:mdex, "~> 0.11.0"},
      {:hammer, "~> 7.0"},
      {:mimic, "~> 2.0", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:tidewave, "~> 0.2", only: :dev}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind elixir_events", "esbuild elixir_events"],
      "assets.deploy": [
        "tailwind elixir_events --minify",
        "esbuild elixir_events --minify",
        "phx.digest"
      ]
    ]
  end
end
