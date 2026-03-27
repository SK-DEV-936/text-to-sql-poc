from abc import ABC, abstractmethod
from typing import Dict, Any

class MarketingSchemaPort(ABC):
    @abstractmethod
    async def get_db_schema_context(self) -> str:
        """Returns the rigorous read-only schema definition for users and orders."""
        pass
        
    @abstractmethod
    async def get_merchant_assets(self, restaurant_id: int) -> Dict[str, Any]:
        """Returns a merchant's website and gallery links."""
        pass

class MarketingAiPort(ABC):
    @abstractmethod
    async def generate_strategy(self, merchant_data: Dict[str, Any]) -> str:
        """Invokes the Growth Manager strategically."""
        pass
