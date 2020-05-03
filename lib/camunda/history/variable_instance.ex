defmodule Camunda.History.VariableInstance do
  @moduledoc ~S"""
  Module for working with variable instances
  """

  @list "/history/variable-instance"

  @doc ~S"""
  Returns list of process instances history
  """
  def list(username, password, body \\ %{}, options \\ [])

  def list(username, password, body, options) do
    with req_headers <- ApiInstance.get_basic_header(username, password),
         {:ok, encoded_body} <- Jason.encode(body),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.post(@list, encoded_body, req_headers, options),
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
      _ -> {:error, "Unknown error of Camunda.History.VariableInstance.list/3"}
    end
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
