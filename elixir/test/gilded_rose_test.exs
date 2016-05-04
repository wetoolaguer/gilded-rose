defmodule GildedRoseTest do
  use ExUnit.Case

  #Backstage Passess

  @backstage_pass %Item{
    name: "Backstage passes to a TAFKAL80ETC concert",
    sell_in: 9,
    quality: 1
  }

  @aged_brie %Item{
    name: "Aged Brie",
    sell_in: 9,
    quality: 1
  }

  @sulfuras %Item{
    name: "Sulfuras, Hand of Ragnaros",
    sell_in: 9,
    quality: 1
  }

  @conjured %Item{
    name: "+5 Dexterity Vest",
    sell_in: 9,
    quality: 10
  }

  @normal %Item{
    name: "Normal Item",
    sell_in: 10,
    quality: 10
  }

  ### True tests
  test "update_item returns unsellable items" do
    assert GildedRose.update_item(@sulfuras) == @sulfuras
  end

  test "update_item downgrades item if downgradable" do
    broken = %{@normal | quality: 0}
    new = %{@normal | sell_in: 10}
    old = %{@normal | sell_in: 0}
    expired = %{@normal | sell_in: -1}

    assert GildedRose.update_item(broken) == broken
    assert GildedRose.update_item(new).quality == old.quality - 1
    assert GildedRose.update_item(old).quality == old.quality - 1
    assert GildedRose.update_item(expired).quality == expired.quality - 2
  end

  test "update_item upgrades backstage_pass if upgradable" do
    max = %{@backstage_pass | quality: 50}
    new = %{@backstage_pass | sell_in: 10}
    old = %{@backstage_pass | sell_in: 0}
    expired = %{@backstage_pass | sell_in: -1}

    assert GildedRose.update_item(max) == max
    assert GildedRose.update_item(new).quality == old.quality + 2
    assert GildedRose.update_item(old).quality == old.quality + 3
    assert GildedRose.update_item(expired).quality == 0
  end

  test "update_item downgrades conjured twice as fast" do
    broken = %{@conjured | quality: 0}
    new = %{@conjured | sell_in: 10}
    old = %{@conjured | sell_in: 0}
    expired = %{@conjured | sell_in: -1}

    assert GildedRose.update_item(broken) == broken
    assert GildedRose.update_item(new).quality == old.quality - 2
    assert GildedRose.update_item(old).quality == old.quality - 2
    assert GildedRose.update_item(expired).quality == expired.quality - 4
  end

  ### Handles
  test "returns item if quality == 0" do
    item = %{@backstage_pass | quality: 0}
    assert GildedRose.update_item(item) == item
  end

  test "Backstage Pass: quality = 0 if sellin < 0" do
    item = %{@backstage_pass | sell_in: -10}
    assert GildedRose.update_item(item).quality == 0
  end

  test "Backstage Pass: quality + 2 if sell_in > 5 || sellin <= 10" do
    item = %{@backstage_pass | sell_in: 6}
    assert GildedRose.update_item(item).quality == item.quality + 2
  end

  test "Backstage Pass: quality + 3 if sell_in >= 0 || sellin <= 5" do
    item = %{@backstage_pass | sell_in: 0}
    assert GildedRose.update_item(item).quality == item.quality + 3
  end

  test "Aged Brie: quality + 1 if quality < 50 " do
    item = %{@aged_brie | quality: 10}
    assert GildedRose.update_item(item).quality == item.quality + 1
  end

  test "Aged Brie: returns item if quality >= 50 " do
    item = %{@aged_brie | quality: 50}
    assert GildedRose.update_item(item) == item
  end

  test "Backstage Pass: quality = 0 if sellin < 0" do
    item = %{@backstage_pass | sell_in: -1}
    assert GildedRose.update_item(item).quality == 0
  end

  test "Conjured: quality - 2 if sell_in < 0" do
    item = %{@conjured | sell_in: -1, quality: 10}
    assert GildedRose.update_item(item).quality == item.quality - 4
  end

  test "NonConjured and NonBackstage: returns item if sell_in < 0" do
    item = %{@aged_brie | sell_in: -1, quality: 50}
    assert GildedRose.update_item(item) == item
  end
  
  test "Conjured: quality - 2 if sell_in > 0" do
    item = %{@conjured | sell_in: 5, quality: 5}
    assert GildedRose.update_item(item).quality == item.quality - 2
  end

  test "Sulfuras (Legendary item): doesn't degrade" do
    assert GildedRose.update_item(@sulfuras) == @sulfuras
  end
end
