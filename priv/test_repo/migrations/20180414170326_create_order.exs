defmodule BeepBop.TestRepo.Migrations.CreateOrder do
  use Ecto.Migration

  def change do
    create table("order") do
      add :state, :string
    end
  end
end
