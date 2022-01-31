defmodule Mix.Tasks.Utils.AddFakeFriends do
  use Mix.Task
  alias NimbleCSV.RFC4180, as: Parser
  alias FriendsApp.CLI.Friend.Friend

  @shortdoc "Add friends to app"
  def run(_) do
    Faker.start()

    create_friends([], 50)
    |> Parser.dump_to_iodata()
    |> save_file()
  end

  defp create_friends(list, count) when count <= 1 do
    list ++ [random_list_friend()]
  end

  defp create_friends(list, count) do
    list ++ [random_list_friend()] ++ create_friends(list, count - 1)
  end

  defp random_list_friend do
    %Friend{
      name: Faker.Person.PtBr.name(),
      email: Faker.Internet.email(),
      phone: Faker.Phone.EnUs.phone()
    }
    |> Map.from_struct()
    |> Map.values()
  end

  defp save_file(data) do
    Application.fetch_env!(:friends_app, :csv_file_path)
    |> File.write!(data, [:append])
  end
end
