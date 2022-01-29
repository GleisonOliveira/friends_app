defmodule FriendsApp.CLI.Menu.Items do
  alias FriendsApp.CLI.Menu.Menu

  def all, do: [
    %Menu{ label: "Listar os amigos", id: :read },
    %Menu{ label: "Cadastrar um amigo", id: :create },
    %Menu{ label: "Atualizar um amigo", id: :update },
    %Menu{ label: "Apagar um amigo", id: :delete },
  ]
end
