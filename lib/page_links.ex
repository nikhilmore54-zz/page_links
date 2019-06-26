defmodule PageLinks do
  @moduledoc """
  FetchLinks module is developed as a response to recruitment 
  process of UpLearn. This module shall accept a URL and list 
  out the assets and links on that page, if it exists
  """ 

  @max_redirects 5

  @doc """
  
  """
  def fetch_url(url) do
    fetch_url(url, 0)
  end

  defp fetch_url(url, redirect_count) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, 
            body: body}}  ->
        body
        |> parse_for_tags(%{a: [], img: []})
        |> create_asset_list

      {:ok, %HTTPoison.Response{status_code: 302, 
            headers: headers}} ->
        if redirect_count < @max_redirects do
          for {header_type, header_value}
            when header_type == "Location" <- headers do
              fetch_url(header_value, redirect_count + 1)
          end
          |> List.first
        else
          {:error, message: "Maximum redirect limit exceeded"}
        end
        
      {:error, error_tuple} ->
        {:error, error_tuple}        
    end   
  end

  defp parse_for_tags(body, assets_elements) do
    %{
      img: assets_elements.img ++ Floki.find(body, "img"),
      a:   assets_elements.a   ++ Floki.find(body, "a")
    }
  end

  defp create_asset_list(%{a: a_tags, img: img_tags}) do
    links = for {"a", list_resources, _text} <- a_tags do
      with {type, link} when type == "href" <- list_resources do
        IO.inspect link
        link
      end
    end
    |> List.flatten

    assets = for {"img", list_resources, _text} <- img_tags do
      with {type, asset} when type == "src"
              <- list_resources do
        asset
      end
    end
    |> List.flatten

    {:ok, %{links: links, assets: assets}}
  end
end
