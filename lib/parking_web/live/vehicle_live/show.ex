defmodule ParkingWeb.VehicleLive.Show do
  use ParkingWeb, :live_view

  alias Parking.Customers

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {
      :noreply,
      socket
      |> assign(:page_title, "Show Vehicle")
      |> assign(:vehicle, Customers.get_vehicle!(id))
    }
  end
end