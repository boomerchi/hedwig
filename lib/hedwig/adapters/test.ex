defmodule Hedwig.Adapters.Test do
  @moduledoc false

  use Hedwig.Adapter

  def init({robot, opts}) do
    {:ok, %{conn: nil, opts: opts, robot: robot}}
  end

  def handle_cast({:send, msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:message, msg})
    {:noreply, state}
  end

  def handle_cast({:reply, %{text: text, user: user} = msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:message, %{msg | text: "#{user}: #{text}"}})
    {:noreply, state}
  end

  def handle_cast({:emote, %{text: text} = msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:message, %{msg | text: "* #{text}"}})
    {:noreply, state}
  end

  def handle_info({:message, msg}, %{robot: robot} = state) do
    msg = %Hedwig.Message{adapter: {__MODULE__, self}, text: msg.text, user: msg.user}
    Hedwig.Robot.handle_message(robot, msg)
    {:noreply, state}
  end
end
