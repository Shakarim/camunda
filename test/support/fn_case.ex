defmodule Camunda.FnCase do
  @moduledoc """
  Case with additional functions for testing
  """

  @doc """
  Returns tuple with cofigured username and password for testing
  """
  def get_auth_data do
    {
      Keyword.get(Application.get_env(:camunda, :camunda), :username, nil),
      Keyword.get(Application.get_env(:camunda, :camunda), :password, nil)
    }
  end
end
