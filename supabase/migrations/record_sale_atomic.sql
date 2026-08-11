-- ============================================================
-- record_sale_atomic RPC function
-- Run this in your Supabase SQL Editor
-- ============================================================

CREATE OR REPLACE FUNCTION record_sale_atomic(
  p_recipe_id UUID,
  p_quantity INTEGER,
  p_unit_price DOUBLE PRECISION,
  p_total_amount DOUBLE PRECISION,
  p_user_id UUID
) RETURNS SETOF sales AS $$
DECLARE
  v_ingredient RECORD;
  v_sale_id UUID;
  v_needed_qty REAL;
BEGIN
  INSERT INTO sales (recipe_id, quantity, unit_price, total_amount, recorded_by)
  VALUES (p_recipe_id, p_quantity, p_unit_price, p_total_amount, p_user_id)
  RETURNING id INTO v_sale_id;

  FOR v_ingredient IN
    SELECT ri.inventory_item_id, ri.quantity, ii.cost_per_unit
    FROM recipe_ingredients ri
    JOIN inventory_items ii ON ii.id = ri.inventory_item_id
    WHERE ri.recipe_id = p_recipe_id
  LOOP
    v_needed_qty := v_ingredient.quantity * p_quantity;

    UPDATE inventory_items
    SET stock = GREATEST(0, stock - v_needed_qty),
        updated_at = now()
    WHERE id = v_ingredient.inventory_item_id;

    INSERT INTO stock_movements (
      inventory_item_id,
      type,
      quantity,
      cost_per_unit,
      total_cost,
      note,
      user_id
    ) VALUES (
      v_ingredient.inventory_item_id,
      'sale',
      -v_needed_qty,
      v_ingredient.cost_per_unit,
      v_needed_qty * v_ingredient.cost_per_unit,
      'Sale ' || v_sale_id::text,
      p_user_id
    );
  END LOOP;

  RETURN QUERY SELECT * FROM sales WHERE id = v_sale_id;
END;
$$ LANGUAGE plpgsql

SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION record_sale_atomic(UUID, INTEGER, DOUBLE PRECISION, DOUBLE PRECISION, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION record_sale_atomic(UUID, INTEGER, DOUBLE PRECISION, DOUBLE PRECISION, UUID) TO anon;
