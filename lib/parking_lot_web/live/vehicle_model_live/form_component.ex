defmodule ParkingLotWeb.VehicleModelLive.FormComponent do
  use ParkingLotWeb, :live_component

  alias ParkingLot.Vehicles

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="model-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:brand_id]}
          type="select"
          label={gettext("Brand")}
          prompt={gettext("Choose the brand")}
          options={for brand <- @brands, do: {brand.name, brand.id}}
        />

        <.input
          field={@form[:type_id]}
          type="select"
          label={gettext("Type")}
          prompt={gettext("Choose the type")}
          options={for type <- @types, do: {type.name, type.id}}
        />

        <.input field={@form[:name]} type="text" label={gettext("Model")} />
        <:actions>
          <.button phx-disable-with={gettext("Saving...")}><%= gettext("Save model") %></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{model: model} = assigns, socket) do
    changeset = Vehicles.change_model(model)
    brands = Enum.sort_by(Vehicles.list_brands(), & &1.name)
    types = Enum.sort_by(Vehicles.list_types(), & &1.name)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(brands: brands, types: types)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"model" => model_params}, socket) do
    changeset =
      socket.assigns.model
      |> Vehicles.change_model(model_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"model" => model_params}, socket) do
    save_model(socket, socket.assigns.action, model_params)
  end

  defp save_model(socket, :edit, model_params) do
    case Vehicles.update_model(socket.assigns.model, model_params) do
      {:ok, model} ->
        notify_parent({:saved, model})

        {:noreply,
         socket
         |> put_flash(:info, gettext("Model updated successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_model(socket, :new, model_params) do
    case Vehicles.create_model(model_params) do
      {:ok, model} ->
        notify_parent({:saved, model})

        {:noreply,
         socket
         |> put_flash(:info, gettext("Model created successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
