defmodule Camunda.ProcessDefinition do
  @moduledoc ~S"""
  Module for working with process definition
  """

  @list "/process-definition"
  @start "/process-definition/{process_id}/start"

  def create_process_by_definition_key(username, password, definition_key, business_key \\ "", data \\ %{}, params \\ %{})

  @doc """
  Creates and start camunda process by business key

  ## Examples

    iex> Camunda.ProcessDefinition.create_process_by_definition_key("demo", "demo", "Process_10dwny6")
    {:error, "Process with key Process_10dwny6 not found"}

    iex> Camunda.ProcessDefinition.create_process_by_definition_key("demo", "demo", "ktt_kp")
    {:ok, %{
       "businessKey" => "",
       "caseInstanceId" => nil,
       "definitionId" => "ktt_kp:1:e44f5fa8-8aa7-11ea-bc55-d850e640ee9f",
       "ended" => false,
       "id" => "b5e28f86-8b06-11ea-bc55-d850e640ee9f",
       "links" => [
         %{
           "href" => "http://localhost:8080/engine-rest/process-instance/b5e28f86-8b06-11ea-bc55-d850e640ee9f",
           "method" => "GET",
           "rel" => "self"
         }
       ],
       "suspended" => false,
       "tenantId" => nil
      }
    }

  """
  def create_process_by_definition_key(username, password, definition_key, business_key, data, _params) do
    with {:ok, process_id} <- get_latest_version_of_process_id_by_definition_key(username, password, definition_key),
         request_headers <- ApiInstance.get_basic_header(username, password),
         request_url <- String.replace(@start, "{process_id}", process_id),
         variables <- prepare_variables_map(data),
         {:ok, request_body} <- Jason.encode(%{businessKey: business_key, variables: variables}),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.post(request_url, request_body, request_headers, []),
         {:ok, result} <- ApiInstance.get_request_result(response)
      do
      {:ok, result}
    else
      {status, error} -> {status, error}
      result -> {:error, result}
    end
  end

  @doc """
  Returns id of latest version process by key

  ## Params

    username :: String.t()
    password :: String.t()
    key :: String.t()

  ## Example

    iex> Camunda.ProcessDefinition.get_latest_version_of_process_id_by_definition_key("demo", "demo", "ktt_kp")
    {:ok, "ktt_kp:1:e44f5fa8-8aa7-11ea-bc55-d850e640ee9f"}

  ## Returns

    {:ok, String.t()} | {:error, String.t()}

  """
  def get_latest_version_of_process_id_by_definition_key(username, password, key) do
    with request_headers <- ApiInstance.get_basic_header(username, password),
         request_params <- [params: %{key: key, latestVersion: true}],
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.get(@list, request_headers, request_params),
         {:ok, result} <- ApiInstance.get_request_result(response),
         %{"id" => process_id} <- List.first(result)
      do
      {:ok, process_id}
    else
      {status, error} -> {status, error}
      nil -> {:error, "Process with key #{key} not found"}
      result -> {:error, result}
    end
  end

  # Prepares process instantiation variables map
  defp prepare_variables_map(data), do: Enum.into(Enum.map(data, &prepare_variable/1), %{})

  defp prepare_variable({name, value}) when (is_map(value)), do: {name, %{type: "json", "value": Jason.encode!(value)}}
  defp prepare_variable({name, value}) when (is_list(value)), do: {name, %{type: "json", "value": Jason.encode!(value)}}
  defp prepare_variable({name, value}) when (is_binary(value)), do: {name, %{type: "string", "value": value}}
  defp prepare_variable({name, value}) when (is_float(value)), do: {name, %{type: "float", "value": value}}
  defp prepare_variable({name, value}) when (is_integer(value)), do: {name, %{type: "integer", "value": value}}
  defp prepare_variable({name, value}), do: {name, %{type: "string", "value": value}}
end
