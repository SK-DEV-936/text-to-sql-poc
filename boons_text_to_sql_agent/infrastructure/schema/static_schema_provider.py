from __future__ import annotations

from typing import Any, Dict, Mapping

from boons_text_to_sql_agent.application.ports import SchemaProviderPort
from boons_text_to_sql_agent.domain import Role, Scope


class StaticSchemaProvider(SchemaProviderPort):
    """Temporary hardcoded schema manifest for the POC."""

    def get_schema_manifest(self, scope: Scope) -> Mapping[str, Any]:
        base_schema: Dict[str, Any] = {
                    "tables": {
                                "orders": {
                                            "description": "Table representing regular orders placed by customers.",
                                            "columns": {
                                                        "id": "Unique identifier for the order.",
                                                        "delivery_to_pickup": "Indicates if the order is for delivery or pickup.",
                                                        "delivery_to_pickup_time": "Timestamp for delivery or pickup time.",
                                                        "auto_cancel": "Indicates if the order can be auto-canceled.",
                                                        "delivery_api_failed": "Indicates if the delivery API call failed.",
                                                        "flag": "Status flag for the order.",
                                                        "rs": "Indicates if the order is a restaurant special.",
                                                        "pos": "Indicates if the order is from a POS system.",
                                                        "dc": "Delivery charge.",
                                                        "pu_status": "Pickup status.",
                                                        "spu_status": "Special pickup status.",
                                                        "delay_status": "Indicates if there is a delay in the order.",
                                                        "show_status": "Indicates if the order should be shown.",
                                                        "coupon_amount": "Amount of discount applied via coupon.",
                                                        "coupon_code": "Code of the coupon used.",
                                                        "coupon_id": "Identifier for the coupon.",
                                                        "caterign_charge_percentage_value": "Percentage value for catering charge.",
                                                        "catering_change_title": "Title for any changes in catering.",
                                                        "catering_change": "Amount of change in catering.",
                                                        "delivery_track_id": "Tracking ID for delivery.",
                                                        "quote_estimate_id": "ID for quote estimate.",
                                                        "cancel_fee": "Fee charged for canceling the order.",
                                                        "increment_val": "Increment value for order.",
                                                        "increment_status": "Status of increment.",
                                                        "cart_data": "Data related to the cart.",
                                                        "strip_pass_amt": "Amount passed to Stripe.",
                                                        "order_amount": "Total amount for the order.",
                                                        "email_sending_status": "Status of email sending.",
                                                        "strip_payment_key": "Payment key from Stripe.",
                                                        "delivery_api_status": "Status from the delivery API.",
                                                        "delivery_notes": "Notes related to delivery.",
                                                        "complete_email": "Indicates if a complete email was sent.",
                                                        "code": "Unique code for the order.",
                                                        "oid": "Order ID.",
                                                        "customer_id": "Identifier for the customer.",
                                                        "customer_address_id": "Identifier for the customer's address.",
                                                        "driver_id": "Identifier for the driver.",
                                                        "order_placed_at": "Timestamp when the order was placed.",
                                                        "order_approved_at": "Timestamp when the order was approved.",
                                                        "order_preparing_at": "Timestamp when the order started preparing.",
                                                        "order_prepared_at": "Timestamp when the order was prepared.",
                                                        "order_ready_at": "Timestamp when the order was ready.",
                                                        "order_initiated_at": "Timestamp when the order was initiated.",
                                                        "order_trip_created_at": "Timestamp when the order trip was created.",
                                                        "order_in_progress_at": "Timestamp when the order is in progress.",
                                                        "order_returned_at": "Timestamp when the order was returned.",
                                                        "order_delayed_at": "Timestamp when the order was delayed.",
                                                        "order_pickup_at": "Timestamp when the order was picked up.",
                                                        "order_picked_up_at": "Timestamp when the order was picked up.",
                                                        "order_auto_cancel_at": "Timestamp when the order was auto-canceled.",
                                                        "order_delivered_at": "Timestamp when the order was delivered.",
                                                        "order_pickuped_at": "Timestamp when the order was picked up.",
                                                        "order_canceled_at": "Timestamp when the order was canceled.",
                                                        "order_delivery_canceled_at": "Timestamp when the delivery was canceled.",
                                                        "order_assigned_at": "Timestamp when the order was assigned.",
                                                        "order_scheduled_at": "Timestamp when the order was scheduled.",
                                                        "order_status": "Current status of the order. Valid values are exactly: 'completed', 'cancelled' (with two Ls), or 'returned'.",
                                                        "note": "Additional notes for the order.",
                                                        "total_menu_price": "Total price of the menu items.",
                                                        "total_delivery_charge": "Total delivery charge.",
                                                        "total_vat_amount": "Total VAT amount.",
                                                        "service_fee": "Service fee for the order.",
                                                        "tips_amount": "Amount of tips given.",
                                                        "grand_total": "Grand total amount for the order.",
                                                        "payment_method": "Method of payment used.",
                                                        "payment_details": "Details of the payment.",
                                                        "payment_timestamp": "Timestamp of the payment.",
                                                        "payment_status": "Status of the payment.",
                                                        "type": "Type of order (pickup or delivery).",
                                                        "order_schedule_mode": "Mode of order scheduling.",
                                                        "strip_status": "Status from Stripe.",
                                                        "store_address": "Address of the store.",
                                                        "store_location": "Location of the store.",
                                                        "day": "Day of the order.",
                                                        "schedule": "Schedule for the order.",
                                                        "name": "Customer's first name.",
                                                        "lastname": "Customer's last name.",
                                                        "email": "Customer's email address.",
                                                        "mobile": "Customer's mobile number.",
                                                        "phone_isd_code": "ISD code for the phone number.",
                                                        "apartment": "Apartment number for delivery.",
                                                        "delivery_add": "Additional delivery address.",
                                                        "delivery_address_type": "Type of delivery address.",
                                                        "deliver_cod": "Cash on delivery details.",
                                                        "order_type": "Type of order.",
                                                        "order_mode": "Mode of the order.",
                                                        "order_schedule": "Schedule for the order.",
                                                        "order_schedule_time": "Time for the scheduled order.",
                                                        "deliveryStatus": "Status of delivery.",
                                                        "admin_refund": "Refund details from admin.",
                                                        "created_date": "Timestamp when the order was created.",
                                                        "ip_data": "IP data related to the order.",
                                                        "receipt_url": "URL for the receipt.",
                                                        "stripe_charge": "Charge details from Stripe.",
                                                        "stripe_capture": "Capture details from Stripe.",
                                                        "refund_details": "Details of any refunds.",
                                                        "tracking_info": "Tracking information for the order.",
                                                        "admin_discount": "Discount applied by admin.",
                                                        "admin_add": "Additional amount added by admin.",
                                                        "admin_reason": "Reason for admin actions.",
                                                        "stripe_create_array": "Array of Stripe creation details.",
                                                        "stripe_create_array_data": "Data related to Stripe creation.",
                                                        "alert_5": "Alert status for 5 minutes.",
                                                        "alert_10": "Alert status for 10 minutes.",
                                                        "alert_15": "Alert status for 15 minutes.",
                                                        "alert_20": "Alert status for 20 minutes.",
                                                        "alert_30": "Alert status for 30 minutes.",
                                                        "alert_25": "Alert status for 25 minutes.",
                                                        "alert_60": "Alert status for 60 minutes.",
                                                        "alert_120": "Alert status for 120 minutes.",
                                                        "alert_180": "Alert status for 180 minutes.",
                                                        "stripe_payment_intent_id": "Payment intent ID from Stripe.",
                                                        "partyware": "Details about partyware for the order.",
                                                        "order_source": "Source of the order (web, app, etc.).",
                                                        "tracking_token": "Token for tracking the order.",
                                                        "show_order_in_app": "Indicates if the order should be shown in the app.",
                                                        "pos_note": "Notes related to POS.",
                                                        "pos_order_api": "API details for POS order.",
                                                        "pos_order_request": "Request details for POS order.",
                                                        "pos_order_response": "Response details for POS order.",
                                                        "pos_orderId": "Order ID from POS.",
                                                        "pos_cancel_api": "API details for canceling POS order.",
                                                        "pos_cancel_request": "Request details for canceling POS order.",
                                                        "pos_cancel_response": "Response details for canceling POS order.",
                                                        "redemption_amount": "Amount redeemed in this order.",
                                                        "user_selection": "User's selection for the order.",
                                                        "kiosk_order_id": "Order ID from kiosk.",
                                                        "order_token": "Token for the order.",
                                                        "token_expiry": "Expiry time for the token.",
                                                        "token_status": "Status of the token."
                                            }
                                }
                    },
                    "relationships": [
                                {
                                            "from": "order_details.order_code",
                                            "to": "orders.code"
                                },
                                {
                                            "from": "catering_order_details.order_code",
                                            "to": "catering_orders.code"
                                },
                                {
                                            "from": "order_history.order_id",
                                            "to": "orders.code"
                                },
                                {
                                            "from": "order_history.order_id",
                                            "to": "catering_orders.code"
                                }
                    ]
        }

        if scope.role == Role.MERCHANT:
            base_schema["role"] = "merchant"
        else:
            base_schema["role"] = "internal"

        return base_schema
