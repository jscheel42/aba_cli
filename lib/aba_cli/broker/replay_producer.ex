defmodule AbaCLI.Broker.ReplayProducer do
  
  use AMQP

  @url         "amqp://rabbitmq:wabbits@apps01.homenet"
  @exchange    "gen_server_test_exchange"
  @queue       "gen_server_test_queue"
  @queue_error "#{@queue}_error"

  # def init(_opts) do
  #   {:ok, conn} = Connection.open(@url)
  #   {:ok, chan} = Channel.open(conn)
  #   setup_queue(chan)

  #   # Limit unacknowledged messages to 10
  #   Basic.qos(chan, prefetch_count: 10)
  #   # Register the GenServer process as a consumer
  #   {:ok, _producer_tag} = Basic.publish(chan, @queue)
  #   {:ok, chan}
  # end
  
  # defp setup_queue() do
  #   {:ok, conn} = Connection.open(@url)
  #   {:ok, chan} = Channel.open(conn)

  #   Queue.declare(chan, @queue_error, durable: true, persistent: true)
  #   # Messages that cannot be delivered to any consumer in the main queue will be routed to the error queue
  #   Queue.declare(chan, @queue, durable: true, persistent: true,
  #                               arguments: [{"x-dead-letter-exchange", :longstr, ""},
  #                                           {"x-dead-letter-routing-key", :longstr, @queue_error}])
  #   Exchange.fanout(chan, @exchange, durable: true)
  #   Queue.bind(chan, @queue, @exchange)

  #   # Limit unacknowledged messages to 10
  #   Basic.qos(chan, prefetch_count: 10)
  #   # Register the GenServer process as a consumer
  #   # {:ok, _producer_tag} = Basic.publish(chan, @queue)
  #   {chan, exchange}
  # end  

  def produce_range() do
    {:ok, conn} = Connection.open(@url)
    {:ok, chan} = Channel.open(conn)

    Queue.declare(chan, @queue_error, durable: true, persistent: true)
    # Messages that cannot be delivered to any consumer in the main queue will be routed to the error queue
    Queue.declare(chan, @queue, durable: true, persistent: true,
                                arguments: [{"x-dead-letter-exchange", :longstr, ""},
                                            {"x-dead-letter-routing-key", :longstr, @queue_error}])
  
    Exchange.fanout(chan, @exchange, durable: true)
    Queue.bind(chan, @queue, @exchange)

    yesterday = Date.utc_today() |> Date.add(-1) |> Date.to_string
    min_replay_id = AbaCLI.Replay.get_next_replay_id
    {:ok, recent_replays} = AbaAPI.Replay.replays(%{start_date: yesterday})

    id_list =
      List.foldl recent_replays, [], fn map, acc ->
        replay_id = Map.get(map, "id")
        [ replay_id | acc ]
      end
    
    max_replay_id = 
      id_list
      |> Enum.sort
      |> List.last

    min_replay_id..max_replay_id
    |> Enum.each(fn replay_id ->
      Basic.publish(chan, @exchange, "", to_string(replay_id))
      IO.puts replay_id
    end)
  end
end
