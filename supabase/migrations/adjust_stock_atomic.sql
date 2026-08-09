-- ============================================================
-- adjust_stock_atomic RPC function
-- Run this in your Supabase SQL Editor
-- ============================================================

CREATE OR REPLACE FUNCTION adjust_stock_atomic(
  p_item_id UUID,
  p_change_qty REAL,
  p_cost_per_unit REAL,
  p_user_id UUID,
  p_note TEXT DEFAULT NULL
) RETURNS SETOF inventory_items AS $$
DECLARE
  v_new_stock REAL;
BEGIN
  UPDATE inventory_items
  SET stock = stock + p_change_qty,
      cost_per_unit = CASE WHEN p_cost_per_unit > 0 THEN p_cost_per_unit ELSE cost_per_unit END,
      updated_at = now()
  WHERE id = p_item_id
  RETURNING stock INTO v_new_stock;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Item not found: %', p_item_id;
  END IF;

  INSERT INTO stock_movements (
    inventory_item_id,
    type,
    quantity,
    cost_per_unit,
    total_cost,
    note,
    user_id
  ) VALUES (
    p_item_id,
    'adjustment',
    p_change_qty,
    p_cost_per_unit,
    ABS(p_change_qty) * p_cost_per_unit,
    p_note,
    p_user_id
  );

  RETURN QUERY SELECT * FROM inventory_items WHERE id = p_item_id;
END;
$$ LANGUAGE plpgsql

SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION adjust_stock_atomic(UUID, REAL, REAL, UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION adjust_stock_atomic(UUID, REAL, REAL, UUID, TEXT) TO anon;
