CREATE TABLE IF NOT EXISTS marketing_campaigns (
    id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT NOT NULL,
    campaign_name VARCHAR(255) NOT NULL,
    strategy_rationale TEXT,
    target_segment_logic TEXT,
    target_audience_size INT DEFAULT 0,
    offer_type VARCHAR(100),
    estimated_conversion_rate FLOAT,
    status VARCHAR(50) DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS marketing_merchant_assets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT NOT NULL,
    asset_type VARCHAR(50) NOT NULL,
    asset_url TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Note: We STRICTLY refrain from ALTERING existing 'users', 'restaurants', 'catering_orders' tables.
-- The Marketing Agent module operates in an explicitly read-only manner against them.
