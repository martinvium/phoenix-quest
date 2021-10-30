require IEx
require Logger

defmodule PhoenixQuestWeb.GameLive do
  use PhoenixQuestWeb, :live_view

  @width 30

  @board [
    ~w(X X X X X X X X X X X X X X X X X X X X X X X X X X X X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 X X X X X X X X X X X 0 0 X X X X X X X X X X X 0 X),
    ~w(X 0 X R R R R X R R R R X 0 0 X R R R R R X R R R X 0 X),
    ~w(X 0 R R R R R X R R R R X 0 0 X R R R R R X R R R X 0 X),
    ~w(X 0 X R R R R X R R R R X 0 0 X R R R R R X R R R X 0 X),
    ~w(X 0 X R R R R X R R R R X 0 0 X R R R R R X R R R X 0 X),
    ~w(X 0 X R R R R X R R R R X 0 0 X R R R R R X R R R X 0 X),
    ~w(X 0 X X X X X X X X X X X 0 0 X X X X X X X X X X X 0 X),
    ~w(X 0 X R R R R R X R R R X 0 0 X R R R R R X R R R X 0 X),
    ~w(X 0 X R R R R R X R R R X 0 0 X R R R R R X R R R X 0 X),
    ~w(X 0 X R R R R R X R R R X 0 0 X R R R R R X R R R X 0 X),
    ~w(X 0 X R R R R R X R R R X 0 0 X R R R R R X R R R X 0 X),
    ~w(X 0 X X X X X X X X X X X 0 0 X X X X X X X X X X X 0 X),
    ~w(X 0 X R R R R R X 0 0 0 0 0 0 0 0 0 0 X R R R R R X 0 X),
    ~w(X 0 X R R R R R X 0 X X X X X X X X 0 X R R R R R X 0 X),
    ~w(X 0 X R R R R R X 0 X R R R R R R X 0 X R R R R R X 0 X),
    ~w(X 0 X X X X X X X 0 X R R R R R R X 0 X X X X X X X 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 X R R R R R R X 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 X R R R R R R X 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 X R R R R R R X 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 X R R R R R R X 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 X X X X X X X X 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X X X X X X X X X X X X X X X X X X X X X X X X X X X X)
  ]
  @board_rows length(@board)
  @board_cols length(hd(@board))

  def render(%{game_state: :over} = assigns) do
    ~H"""
    <div class="game-container">
      <div class="game-over">
        <h1>GAME OVER</h1>
        <button phx-click="new_game">NEW GAME</button>
      </div>
    </div>
    """
  end

  def render(%{game_state: :playing} = assigns) do
    ~H"""
    <div class="game-controls">
      <form phx-change="update_settings">
        <input type="range" min="5" max="50" name="width" value={@width} />
        <%= @width %>px
      </form>
    </div>
    <div class="game-container" phx-window-keydown="keydown">
      <%= for unit <- @units do %>
        <div class={"block #{unit.type}"}
            style={"left: #{x(unit.x, @width)}px;
                    top: #{y(unit.y, @width)}px;
                    width: #{unit.width}px;
                    height: #{unit.width}px;"}
        ></div>
      <% end %>
      <%= for {_, block} <- @blocks, block.type do %>
        <div class={"block #{block.type}"}
            style={"left: #{block.x}px;
                    top: #{block.y}px;
                    width: #{block.width}px;
                    height: #{block.width}px;"}
        ></div>
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket |> new_game()}
  end

  defp new_game(socket) do
    defaults = %{
      game_state: :playing,
      heading: :stationary,
      pending_headings: {:stationary, []},
      width: @width,
      row: 6,
      col: 6,
      units: [player(6, 6), monster(5, 10), monster(1, 7)]
    }

    socket
    |> assign(defaults)
    |> build_board()
    # |> build_units()
  end

  def handle_event("update_settings", %{"width" => width}, socket) do
    {width, ""} = Integer.parse(width)

    new_socket =
      socket
      |> update_size(width)

    {:noreply, new_socket}
  end

  def handle_event("new_game", _, socket) do
    {:noreply, new_game(socket)}
  end

  def handle_event("keydown", %{"key" => key}, socket) do
    new_socket =
      socket
      |> turn(key)
      |> game_loop()

    {:noreply, new_socket}
  end

  defp update_size(socket, width) do
    socket
    |> assign(width: width)
    |> build_board()
  end

  defp turn(socket, "ArrowLeft"), do: go(socket, :left)
  defp turn(socket, "ArrowDown"), do: go(socket, :down)
  defp turn(socket, "ArrowUp"), do: go(socket, :up)
  defp turn(socket, "ArrowRight"), do: go(socket, :right)
  defp turn(socket, _), do: socket

  defp go(socket, heading) do
    update(socket, :pending_headings, fn
      {^heading, prev} -> {heading, prev}
      {_, prev} -> {heading, prev ++ [heading]}
    end)
  end

  defp next_heading(socket) do
    {next, pending} =
      case {socket.assigns.heading, socket.assigns.pending_headings} do
        {current, {_, []}} -> {current, []}
        {_current, {_, [new | rest]}} -> {new, rest}
      end

    {next, {next, pending}}
  end

  defp game_loop(%{assigns: %{pending_headings: {:stationary, []}}} = socket), do: socket

  defp game_loop(socket) do
    {heading, new_pending} = next_heading(socket)
    {row_before, col_before} = coord(socket)
    maybe_row = row(row_before, heading)
    maybe_col = col(col_before, heading)

    Logger.debug "#{maybe_row}, #{maybe_col}: #{get_tile_type(socket, maybe_row, maybe_col)}"
    {row, col, collision} =
      case get_tile_type(socket, maybe_row, maybe_col) do
        :wall -> {maybe_row, maybe_col, :wall}
        :unit -> {maybe_row, maybe_col, :unit}
        :empty -> {maybe_row, maybe_col, :empty}
        :room -> {maybe_row, maybe_col, :room}
      end

    socket
    |> move_player({row_before, row}, {col_before, col})
    |> update(:row, fn _ -> row end)
    |> update(:col, fn _ -> col end)
    |> update(:heading, fn _ -> heading end)
    |> update(:pending_headings, fn _ -> new_pending end)
    |> handle_collision(collision)
  end

  defp move_player(socket, {row, row}, {col, col}), do: socket

  defp move_player(socket, {_row_before, row}, {_col_before, col}) do
    units = Enum.reduce(socket.assigns.units, [], fn
      %{ type: :player } = unit, acc -> [%{unit | y: row, x: col} | acc]
      unit, acc -> [unit | acc]
    end)

    assign(socket, :units, units)
  end

  def handle_collision(socket, :wall), do: game_over(socket)
  def handle_collision(socket, :unit), do: game_over(socket)
  def handle_collision(socket, :empty), do: socket
  def handle_collision(socket, :room), do: socket

  defp game_over(socket), do: assign(socket, :game_state, :over)

  defp col(val, :left) when val - 1 >= 0, do: val - 1
  defp col(val, :right) when val + 1 < @board_cols, do: val + 1
  defp col(val, _), do: val

  defp row(val, :up) when val - 1 >= 0, do: val - 1
  defp row(val, :down) when val + 1 < @board_rows, do: val + 1
  defp row(val, _), do: val

  def get_tile_type(socket, row, col) do
    cond do
      %{y: row, x: col} in socket.assigns.units -> :unit
      true -> Map.fetch!(socket.assigns.blocks, {row, col}).type
    end
  end

  defp x(x, width), do: x * width
  defp y(y, width), do: y * width

  defp coord(socket), do: {socket.assigns.row, socket.assigns.col}

  defp build_board(socket) do
    width = socket.assigns.width

    {_, blocks} =
      Enum.reduce(@board, {0, %{}}, fn row, {y_idx, acc} ->
        {_, blocks} =
          Enum.reduce(row, {0, acc}, fn
            "X", {x_idx, acc} ->
              {x_idx + 1, Map.put(acc, {y_idx, x_idx}, wall(x_idx, y_idx, width))}

            "R", {x_idx, acc} ->
              {x_idx + 1, Map.put(acc, {y_idx, x_idx}, room(x_idx, y_idx, width))}

            "0", {x_idx, acc} ->
              {x_idx + 1, Map.put(acc, {y_idx, x_idx}, empty(x_idx, y_idx, width))}
          end)

        {y_idx + 1, blocks}
      end)

    assign(socket, :blocks, blocks)
  end

  defp player(x, y) do
    %{type: :player, x: x, y: y, width: @width}
  end

  defp monster(x, y) do
    %{type: :monster, x: x, y: y, width: @width}
  end

  defp wall(x_idx, y_idx, width) do
    %{type: :wall, x: x_idx * width, y: y_idx * width, width: width}
  end

  defp empty(x_idx, y_idx, width) do
    %{type: :empty, x: x_idx * width, y: y_idx * width, width: width}
  end

  defp room(x_idx, y_idx, width) do
    %{type: :room, x: x_idx * width, y: y_idx * width, width: width}
  end
end
