defmodule Sg90Servo.MixProject do
  use Mix.Project

  def project do
    [
      app: :sg90_servo,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      atomvm: [
        start: Sg90Servo,
        flash_offset: 0x250000
      ]
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp deps do
    [
      {:exatomvm, git: "https://github.com/atomvm/exatomvm.git", branch: "main"}
    ]
  end
end
