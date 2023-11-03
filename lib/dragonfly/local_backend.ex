defmodule Dragonfly.LocalBackend do
  @moduledoc false
  @behaviour Dragonfly.Backend

  @impl true
  def init(opts) do
    defaults = Application.get_env(:dragonfly, __MODULE__) || []

    {:ok,
     defaults
     |> Keyword.merge(opts)
     |> Enum.into(%{})}
  end

  @impl true
  def handle_info(_msg, state), do: {:noreply, state}

  @impl true
  def remote_spawn_monitor(_state, term) do
    case term do
      func when is_function(func, 0) ->
        {pid, ref} = spawn_monitor(func)
        {:ok, {pid, ref}}

      {mod, fun, args} when is_atom(mod) and is_atom(fun) and is_list(args) ->
        {pid, ref} = spawn_monitor(mod, fun, args)
        {:ok, {pid, ref}}

      other ->
        raise ArgumentError,
              "expected a null arity function or {mod, func, args. Got: #{inspect(other)}"
    end
  end

  @impl true
  def system_shutdown, do: :noop

  @impl true
  def remote_boot(state) do
    {:ok, state}
  end
end
