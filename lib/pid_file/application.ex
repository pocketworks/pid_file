defmodule PidFile.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    worker =
      case Application.get_env(:pid_file, :file, nil) do
        nil ->
          []

        file when is_binary(file) ->
          [{PidFile.Worker, [file: file]}]

        {:SYSTEM, env_var} when is_binary(env_var) or is_list(env_var) ->
          env_var = if is_list(env_var), do: IO.iodata_to_binary(env_var), else: env_var

          case System.get_env(env_var) do
            nil -> throw("Missing Environment Variable:  #{env_var}")
            file -> [{PidFile.Worker, [file: file]}]
          end
      end

    children = worker

    opts = [strategy: :one_for_one, name: PidFile.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
