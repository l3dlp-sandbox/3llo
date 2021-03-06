require "spec_helper"

describe "board select <board_key>", type: :integration do
  include IntegrationSpecHelper

  before { $application = build_container() }
  after { $application = nil }

  it "selects the given board" do
    board_id = "board:1"

    make_client_mock($application) do |client_mock|
      payload = {"id" => "board:1", "name" => "Board 1"}

      expect(client_mock).to(
        receive(:get)
        .with(
          req_path("/boards/#{board_id}"),
          {}
        )
        .and_return(payload)
      )
    end

    make_interface($application)

    execute_command("board select #{board_id}")

    selected_board = Tr3llo::Application.fetch_board!()
    expect(selected_board.id).to eq(board_id)
  end

  it "accepts selection using board shortcut" do
    board_id = "board:1"

    board_key = Tr3llo::Application.fetch_registry!().register(:board, board_id)

    make_client_mock($application) do |client_mock|
      payload = {"id" => "board:1", "name" => "Board 1"}

      expect(client_mock).to(
        receive(:get)
        .with(
          req_path("/boards/#{board_id}"),
          {}
        )
        .and_return(payload)
      )
    end

    make_interface($application)

    execute_command("board select #" + board_key)

    selected_board = Tr3llo::Application.fetch_board!()
    expect(selected_board.id).to eq(board_id)
  end

  it "handles invalid board key" do
    interface = make_interface($application)
    execute_command("board select #does_not_exist")

    output_string = interface.output.string

    expect(output_string).to match("\"#does_not_exist\" is not a valid board key")
  end
end
