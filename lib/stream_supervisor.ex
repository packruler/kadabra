defmodule Kadabra.StreamSupervisor do
  @moduledoc false

  use Supervisor
  import Supervisor.Spec

  alias Kadabra.Stream

  def start_link(ref) do
    name = via_tuple(ref)
    Supervisor.start_link(__MODULE__, :ok, name: name)
  end

  def via_tuple(ref) do
    {:via, Registry, {Registry.Kadabra, {ref, __MODULE__}}}
  end

  def start_opts(id \\ :erlang.make_ref()) do
    [id: id, restart: :transient]
  end

  def start_stream(%{ref: ref} = config, flow, stream_id \\ nil) do
    stream = Stream.new(config, flow.settings, stream_id || flow.stream_id)
    Supervisor.start_child(via_tuple(ref), [stream])
  end

  def init(:ok) do
    spec = worker(Stream, [], start_opts())
    supervise([spec], strategy: :simple_one_for_one)
  end
end
