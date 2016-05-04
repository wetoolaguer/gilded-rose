defmodule GildedRose do
  # Example
  # update_quality([%Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 9, quality: 1}])
  # => [%Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 9, quality: 3}]

  @backstage_pass "Backstage passes to a TAFKAL80ETC concert"
  @upgrades_by_age [@backstage_pass, "Aged Brie"]
  @legendaries ["Sulfuras, Hand of Ragnaros"]
  @conjured ["+5 Dexterity Vest", "Elixir of the Mongoose"]
  @min_quality 0
  @max_quality 50

  def update_quality(items) do
    Enum.map(items, &update_item/1)
  end

  def update_item(item) do
    cond do
      unsellable?(item) -> item
      unmodifiable?(item) -> item
      conjured?(item) -> downgrade_conjured(item)
      upgrades_by_age?(item) -> upgrade_item(item)
      true -> downgrade_item(item)
    end
  end

  defp upgrade_item(item = %{name: name}) when name == @backstage_pass do
    cond do
      new?(item) -> upgrade_by(item, 2)
      old?(item) -> upgrade_by(item, 3)
      expired?(item) -> downgrade_by(item, item.quality)
      true -> item
    end
  end

  defp upgrade_item(item) do
    cond do
      new?(item) -> upgrade_by(item, 1)
      old?(item) -> upgrade_by(item, 1)
      expired?(item) -> item
      true -> item
    end
  end

  defp downgrade_item(item)  do
    cond do
      new?(item) -> downgrade_by(item, 1)
      old?(item) -> downgrade_by(item, 1)
      expired?(item) -> downgrade_by(item, 2)
      true -> item
    end
  end

  defp downgrade_conjured(item) do
    cond do
      new?(item) -> downgrade_by(item, 2)
      old?(item) -> downgrade_by(item, 2)
      expired?(item) -> downgrade_by(item, 4)
      true -> item
    end
  end

  defp upgrade_by(item, count) do
    new_val = item.quality + count
    new_val = if new_val > 50,  do: 50, else: new_val
    %{item | quality: new_val }
  end

  defp downgrade_by(item, count) do
    new_val = item.quality - count
    new_val = if new_val < 0, do: 0, else: new_val
    %{item | quality: new_val }
  end

  defp new?(item) do
    item.sell_in > 5 && item.sell_in <= 10
  end

  defp old?(item) do
    item.sell_in >= 0 && item.sell_in <= 5
  end

  defp expired?(item) do
    item.sell_in < 0
  end

  defp upgrades_by_age?(item) do
    Enum.member?(@upgrades_by_age, item.name)
  end

  defp unsellable?(item) do
    Enum.member?(@legendaries, item.name)
  end

  defp unmodifiable?(item) do
    max?(item) || broken?(item)
  end

  defp max?(item) do
    item.quality >= 50
  end

  defp broken?(item) do
    item.quality <= 0
  end

  defp conjured?(item) do
    Enum.member?(@conjured, item.name)
  end

  #old implementation
  def update_item_2(item) do
    cond do
      #done
      item.quality == 0 ->
        item

      #done
      item.sell_in < 0 && item.name == "Backstage passes to a TAFKAL80ETC concert" ->
        %{item | quality: 0}

      #doing
      item.name == "Aged Brie" || item.name == "Backstage passes to a TAFKAL80ETC concert" ->
        #done
        if item.name == "Backstage passes to a TAFKAL80ETC concert" && item.sell_in > 5 && item.sell_in <= 10 do
          %{item | quality: item.quality + 2}
        else

          #done
          if item.name == "Backstage passes to a TAFKAL80ETC concert" && item.sell_in >= 0 && item.sell_in <= 5 do
            %{item | quality: item.quality + 3}
          else

            if item.quality < 50 do
              %{item | quality: item.quality + 1}
            else
              item
            end
          end
        end

      item.sell_in < 0 ->
        if item.name == "Backstage passes to a TAFKAL80ETC concert" do
          %{item | quality: 0}
        else
          if item.name == "+5 Dexterity Vest" || item.name == "Elixir of the Mongoose" do
            %{item | quality: item.quality - 2}
          else
            item
          end
        end

      item.name == "+5 Dexterity Vest" || item.name == "Elixir of the Mongoose" ->
        %{item | quality: item.quality - 2}

      item.name != "Sulfuras, Hand of Ragnaros" ->
        %{item | quality: item.quality - 1}
      true ->
        item
    end
  end
end
