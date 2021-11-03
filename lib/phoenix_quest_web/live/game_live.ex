require IEx
require Logger

defmodule PhoenixQuestWeb.GameLive do
  use PhoenixQuestWeb, :live_view

  @width 30
  # legend: S -> :stairway

  @board [
    ~w(X X X X X X X X X X X X X X X X X X X X X X X X X X X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X 0 X),
    ~w(X 0 X X X X X X X X R X X 0 X X X X X X X X X X X 0 X),
    ~w(X 0 X R R S S X R R R R X 0 X R F F F R X R R R X 0 X),
    ~w(X 0 X R R S S X R R R R X 0 X R F F F R X R R R X 0 X),
    ~w(X 0 R R R R R X R F F F X 0 R R R R R R R R R R X 0 X),
    ~w(X 0 X R R R R X R F F F X 0 X R R R R R X R R R X 0 X),
    ~w(X 0 X X X X X X X X X X X 0 X X X X R X X X R X X 0 X),
    ~w(X 0 X F F F R F X R R R X 0 X R R R R R X R R R X 0 X),
    ~w(X 0 X F F F R F X R R R X 0 X R R R R R X R R R X 0 X),
    ~w(X 0 R R R R R F X R R R X 0 X R R R R R X R R R X 0 X),
    ~w(X 0 X R R R R R X R R R X 0 X R R R R R X R R R X 0 X),
    ~w(X 0 X X X X X X X X X X X 0 X X X X X X X X X X X 0 X),
    ~w(X 0 X R R R R R X 0 0 0 0 0 0 0 0 0 X R R R R R X 0 X),
    ~w(X 0 X R R R R R X 0 X X X X X X X 0 X R R R R R X 0 X),
    ~w(X 0 X F F F R R X 0 X R R R R R X 0 X R R R R R X 0 X),
    ~w(X 0 X X X X X X X 0 X R R R R R X 0 X X X X X X X 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 X R R R R R X 0 X 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 X R R R R R X 0 X 0 0 0 0 0 0 0 X),
    ~w(X 0 X X X X X X X 0 X R R R R R X 0 X X X X X X X 0 X),
    ~w(X 0 X 0 0 0 0 0 X 0 X R R R R R X 0 X 0 0 0 0 0 X 0 X),
    ~w(X 0 X 0 0 0 0 0 X 0 X X X X X X X 0 X 0 0 0 0 0 X 0 X),
    ~w(X 0 X 0 0 0 0 0 X 0 0 0 0 0 0 0 0 0 X 0 0 0 0 0 X 0 X),
    ~w(X 0 X 0 0 0 0 0 X X X X X 0 X X X X X X X X X X X 0 X),
    ~w(X 0 X 0 0 0 0 0 0 0 0 0 X 0 X 0 0 0 0 0 0 0 0 0 X 0 X),
    ~w(X 0 X 0 0 0 0 0 0 0 0 0 X 0 X 0 0 0 0 0 0 0 0 0 X 0 X),
    ~w(X 0 X 0 0 0 0 0 0 0 0 0 X 0 X 0 0 0 0 0 0 0 0 0 X 0 X),
    ~w(X 0 X 0 0 0 0 0 0 0 0 0 X 0 X 0 0 0 0 0 0 0 0 0 X 0 X),
    ~w(X 0 X 0 0 0 0 0 0 0 0 0 X 0 X 0 0 0 0 0 0 0 0 0 X 0 X),
    ~w(X 0 X 0 0 0 0 0 0 0 0 0 X 0 X 0 0 0 0 0 0 0 0 0 X 0 X),
    ~w(X 0 X X X X X X X X X X X 0 X X X X X X X X X X X 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X X X X X X X X X X X X X X X X X X X X X X X X X X X)
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
      <h3 class="score" style={"font-size: #{@width-2}px;"}>Moves left <%= @moves_left %> of <%= format_rolls(@movement_roll) %></h3>
      <%= for player <- @players do %>
        <div class={"block #{player.type}"}
            phx-click="click_player"
            phx-value-id={player.id}
            style={"left: #{x(player.x, @width)}px;
                    top: #{y(player.y, @width)}px;
                    width: #{player.width}px;
                    height: #{player.width}px;"}
        ></div>
      <% end %>
      <%= for monster <- @monsters do %>
        <div class={"block #{monster.type}"}
            phx-click="click_monster"
            phx-value-id={monster.id}
            style={"left: #{x(monster.x, @width)}px;
                    top: #{y(monster.y, @width)}px;
                    width: #{monster.width}px;
                    height: #{monster.width}px;"}
        ></div>
      <% end %>
      <%= for {_, block} <- @blocks do %>
        <div class={"block #{block.type}"}
            phx-click="click_block"
            phx-value-x={block.x}
            phx-value-y={block.y}
            style={"left: #{block.left}px;
                    top: #{block.top}px;
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
      commands: [],
      width: @width,
      row: 6,
      col: 6,
      turn: 0,
      current_player: 0,
      moves: [],
      moves_left: 0,
      movement_roll: [],
      monsters: [monster(1, 5, 10, @width), monster(2, 1, 7, @width)],
      players: [player(1, 6, 6, @width)]
    }

    socket
    |> assign(defaults)
    |> build_board()
    |> next_turn()
  end

  def next_turn(socket) do
    Logger.debug("next_turn: #{socket.assigns.turn}, #{length(socket.assigns.players)}")

    next_turn = socket.assigns.turn + 1
    movement_roll = roll([6, 6])

    socket
    |> assign(
      turn: next_turn,
      current_player: rem(socket.assigns.turn, length(socket.assigns.players)),
      movement_roll: movement_roll,
      moves_left: Enum.sum(movement_roll )
    )
  end

  defp roll(dice) do
    dice
    |> Enum.map(fn sides -> Enum.random(1..sides) end)
  end

  defp format_rolls(rolls) do
    "#{rolls |> Enum.sum} (#{rolls |> Enum.join(" + ")})"
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
      |> keydown(key)
      |> game_loop()

    {:noreply, new_socket}
  end

  def handle_event("click_player", %{"id" => id}, socket) do
    Logger.debug("click_player: #{id}")
    {:noreply, game_loop(socket)}
  end

  def handle_event("click_monster", %{"id" => id}, socket) do
    Logger.debug("click_monster: #{id}")
    {:noreply, game_loop(socket)}
  end

  def handle_event("click_block", %{"x" => x, "y" => y}, socket) do
    {xint, ""} = Integer.parse(x)
    {yint, ""} = Integer.parse(y)

    Logger.debug("click_block: #{x}, #{y}")

    new_socket = socket
                 |> move(xint, yint)
                 |> game_loop

    {:noreply, new_socket}
  end

  defp move(socket, x, y) do
    { row, col } = coord(socket)
    Logger.debug("move<current>: #{col}, #{row}")

    cond do
      { col, row } == { x + 1, y } -> queue_command(socket, :left)
      { col, row } == { x - 1, y } -> queue_command(socket, :right)
      { col, row } == { x, y + 1 } -> queue_command(socket, :up)
      { col, row } == { x, y - 1 } -> queue_command(socket, :down)
      true -> socket
    end
  end

  defp update_size(socket, width) do
    socket
    |> assign(width: width)
    |> build_board()
  end

  defp keydown(socket, "ArrowLeft"), do: queue_command(socket, :left)
  defp keydown(socket, "ArrowDown"), do: queue_command(socket, :down)
  defp keydown(socket, "ArrowUp"), do: queue_command(socket, :up)
  defp keydown(socket, "ArrowRight"), do: queue_command(socket, :right)
  defp keydown(socket, "1"), do: attack(socket)
  defp keydown(socket, "2"), do: cast_spell(socket)
  defp keydown(socket, "3"), do: search_treasure(socket)
  defp keydown(socket, "4"), do: search_secret_doors(socket)
  defp keydown(socket, "5"), do: search_traps(socket)
  defp keydown(socket, "6"), do: disarm_trap(socket)
  defp keydown(socket, _), do: socket

  defp attack(socket), do: socket
  defp cast_spell(socket), do: socket
  defp search_treasure(socket), do: socket
  defp search_secret_doors(socket), do: socket
  defp search_traps(socket), do: socket
  defp disarm_trap(socket), do: socket

  defp queue_command(socket, command) do
    Logger.debug("queue_command: #{command}")
    update(socket, :commands, fn
      [^command | rest] -> [command | rest]
      rest -> rest ++ [command]
    end)
  end

  defp game_loop(%{assigns: %{commands: []}} = socket), do: socket
  defp game_loop(socket) do
    [next_command | rest_commands] = socket.assigns.commands
    {row_before, col_before} = coord(socket)

    # only for movement?
    maybe_row = row(row_before, next_command)
    maybe_col = col(col_before, next_command)

    Logger.debug "collision_check: #{maybe_row}, #{maybe_col}: #{get_tile_type(socket, maybe_row, maybe_col)}"
    {row, col, collision, consumed} =
      case get_tile_type(socket, maybe_row, maybe_col) do
        :wall -> {row_before, col_before, :wall, 0}
        :stairway -> {maybe_row, maybe_col, :stairway, 1}
        :furnature -> {row_before, col_before, :furnature, 0}
        :player -> {row_before, col_before, :player, 0}
        :monster -> {maybe_row, maybe_col, :monster, 1}
        :empty -> {maybe_row, maybe_col, :empty, 1}
        :room -> {maybe_row, maybe_col, :room, 1}
      end

    socket
    |> move_player({row_before, row}, {col_before, col})
    |> assign(row: row, col: col, commands: rest_commands)
    |> update(:moves, fn moves -> [consumed | moves] end)
    |> update(:moves_left, fn count -> count - consumed end)
    |> handle_collision(collision)
  end

  defp move_player(socket, {row, row}, {col, col}), do: socket
  defp move_player(socket, {_row_before, row}, {_col_before, col}) do
    players = Enum.reduce(socket.assigns.players, [], fn
      %{ type: :player } = player, acc -> [%{player | y: row, x: col} | acc]
      player, acc -> [player | acc]
    end)

    assign(socket, :players, players)
  end

  def handle_collision(socket, :wall), do: socket
  def handle_collision(socket, :stairway), do: game_over(socket)
  def handle_collision(socket, :furnature), do: socket
  def handle_collision(socket, :monster), do: game_over(socket)
  def handle_collision(socket, :player), do: socket
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
      Enum.any?(socket.assigns.players, &(&1.x == col && &1.y == row)) -> :player
      Enum.any?(socket.assigns.monsters, &(&1.x == col && &1.y == row)) -> :monster
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

            "S", {x_idx, acc} ->
              {x_idx + 1, Map.put(acc, {y_idx, x_idx}, stairway(x_idx, y_idx, width))}

            "F", {x_idx, acc} ->
              {x_idx + 1, Map.put(acc, {y_idx, x_idx}, furnature(x_idx, y_idx, width))}

            "0", {x_idx, acc} ->
              {x_idx + 1, Map.put(acc, {y_idx, x_idx}, empty(x_idx, y_idx, width))}
          end)

        {y_idx + 1, blocks}
      end)

    assign(socket, :blocks, blocks)
  end

  defp player(id, x, y, width) do
    unit(:player, id, x, y, width)
  end

  defp monster(id, x, y, width) do
    unit(:monster, id, x, y, width)
  end

  def unit(type, id, x, y, width) do
    %{type: type, id: id, x: x, y: y, left: x * width, top: y * width, width: width}
  end

  defp wall(x, y, width) do
    block(:wall, x, y, width)
  end

  defp empty(x, y, width) do
    block(:empty, x, y, width)
  end

  defp room(x, y, width) do
    block(:room, x, y, width)
  end

  defp stairway(x, y, width) do
    block(:stairway, x, y, width)
  end

  defp furnature(x, y, width) do
    block(:furnature, x, y, width)
  end

  defp block(type, x_idx, y_idx, width) do
    %{type: type, x: x_idx, y: y_idx, left: x_idx * width, top: y_idx * width, width: width}
  end
end
