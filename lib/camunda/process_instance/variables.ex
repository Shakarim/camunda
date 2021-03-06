defmodule Camunda.ProcessInstance.Variables do
  @moduledoc ~S"""
  Module for working with process instance variables
  """

  @list "/process-instance/{id}/variables"
  @modify "/process-instance/{id}/variables"

  @doc """
  Returns list of task variables by username and password

  ## Params

    task :: Map.t()
    username :: String.t()
    password :: String.t()
    options :: Map.t()

  ## Returns

    {:ok, Map.t()} | {:error, String.t()}

  ## Examples

    iex> Camunda.Task.load_variables(%{"id" => "ae4ec37c-8b85-11ea-bc55-d850e640ee9f"},"operator","operator",[params: %{deserializeValues: false}])

  """
  def list(task, username, password, options \\ [])

  def list(%{"id" => task_id} = _task, username, password, options) do
    with request_headers <- ApiInstance.get_basic_header(username, password),
         request_url <- String.replace(@list, "{id}", task_id),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.get(request_url, request_headers, options),
         {:ok, result} <- ApiInstance.get_request_result(response)
      do
      {
        :ok,
        result
        |> Enum.map(&variable_map/1)
        |> Enum.into(%{})
      }
    else
      {status, result} -> {status, result}
      error -> {:error, error}
      _ -> {:error, "Unknown error of Camunda.Task.Variables.list/4"}
    end
  end

  @doc ~S"""
  Sets variable modifications to task
  """
  def modify(task, username, password, modifications, options \\ [])

  def modify(%{"id" => id} = _task, username, password, modifications, options) do
    with request_headers <- ApiInstance.get_basic_header(username, password),
         request_url <- String.replace(@modify, "{id}", id),
         {:ok, encoded_request_body} <- Jason.encode(modifications),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.post(request_url, encoded_request_body, request_headers, options),
         {:no_content, result} <- ApiInstance.get_request_result(response)
      do
      {:ok, result}
    else
      {status, result} -> {status, result}
      error -> {:error, error}
      _ -> {:error, "Unknown error of Camunda.Task.Variables.modify/5"}
    end
  end


  @doc ~S"""
  Creates map with modifications for process instance

  ## Params

    type :: Atom.t()
    name :: String.t()
    value :: String.t() | Integer.t() | Map.t() | List.t() | Keyword.t()

  ## Examples

    Camunda.ProcessInstance.Variables.create_modification(:boolean, "expire", true)

  """
  def create_modification(:string, name, value),
      do: %{"modifications" => %{name => %{"type" => "string", "value" => value}}}

  def create_modification(:integer, name, value),
      do: %{"modifications" => %{name => %{"type" => "integer", "value" => value}}}

  def create_modification(:boolean, name, value) when (is_boolean(value)),
      do: %{"modifications" => %{name => %{"type" => "boolean", "value" => value}}}

  def create_modification(:json, name, value) when (is_binary(value)),
      do: %{"modifications" => %{name => %{"type" => "Json", "value" => value}}}

  def create_modification(:json, name, value) when (is_map(value) or is_list(value)),
      do: %{"modifications" => %{name => %{"type" => "Json", "value" => Jason.encode!(value)}}}

  @doc ~S"""
  Adds string variable into modifications map
  """
  def add_modification(%{"modifications" => modifications} = variables, :string, name, value) do
    modifications = Map.put(modifications, name, %{"type" => "string", "value" => value})
    {:ok, Map.put(variables, "modifications", modifications)}
  end

  def add_modification(variables, :string, name, value) do
    {
      :ok,
      Map.put(
        variables,
        "modifications",
        %{
          name => %{
            "type" => "string",
            "value" => value
          }
        }
      )
    }
  end

  @doc ~S"""
  Adds integer variable into modifications map
  """
  def add_modification(%{"modifications" => modifications} = variables, :integer, name, value) do
    modifications = Map.put(modifications, name, %{"type" => "integer", "value" => value})
    {:ok, Map.put(variables, "modifications", modifications)}
  end

  def add_modification(variables, :integer, name, value) do
    {
      :ok,
      Map.put(
        variables,
        "modifications",
        %{
          name => %{
            "type" => "integer",
            "value" => value
          }
        }
      )
    }
  end

  defp variable_map({key, %{"type" => "Json", "value" => value} = data}) do
    with {:ok, decoded_value} <- Jason.decode(value) do
      {key, Map.put(data, "value", decoded_value)}
    else
      _ -> {key, data}
    end
  end

  defp variable_map({key, data}), do: {key, data}
end
