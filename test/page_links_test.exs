defmodule PageLinksTest do
  use ExUnit.Case
  doctest PageLinks

  test "hits a valid url" do
    {status, _data} = PageLinks.fetch_url("https://www.un.org")
    assert status == :ok
  end

  test "Url is redirected to other location" do
    {status, _data} = PageLinks.fetch_url("http://www.un.org")
    assert status == :ok
  end

  test "Incorrect URL is provided" do
    {status, _message} = PageLinks.fetch_url("https://www.un.org.old")
    assert status == :error
  end
end
