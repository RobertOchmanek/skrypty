# This files contains your custom actions which can be used to run
# custom Python code.
#
# See this guide on how to implement these action:
# https://rasa.com/docs/rasa/custom-actions

from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
import json
import re


# Helper function for checking if given string can be cast to integer
def represents_int(s):
    try:
        int(s)
        return True
    except ValueError:
        return False


class ActionDisplayOpeningHours(Action):

    def name(self) -> Text:
        return 'action_display_opening_hours'

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        day_of_week_values = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
        day_of_week = ''
        hour = ''

        # Obtain day of week and hour that user requested
        for blob in tracker.latest_message['entities']:

            if blob['entity'] == 'day_of_week':
                day_of_week = blob['value']
                day_of_week = day_of_week.capitalize()

            if blob['entity'] == 'hour':
                hour = blob['value']

        # Fetch opening hour from file
        with open('restaurant_data/opening_hours.json') as opening_hours_file:
            opening_hours = json.load(opening_hours_file)

        opening_hours_items = opening_hours.get('items')
        hours = opening_hours_items.get(day_of_week)

        # TODO: use separate intents/action for complete schedule?
        # When user didn't provide any particular day assume general question and display schedule for the week
        if day_of_week == '':

            schedule_items = []

            for day_of_week_value in day_of_week_values:
                schedule_hours = opening_hours_items.get(day_of_week_value)
                opening = schedule_hours.get('open')
                closing = schedule_hours.get('close')

                # If both values are set to 0 display closed
                if (int(opening) == 0) and (int(closing) == 0):
                    schedule_items.append("- " + day_of_week_value + ": closed")
                else:
                    schedule_items.append("- " + day_of_week_value + f": from {opening} to {closing}")

            # Append each day's opening hours in separate line
            schedule_separator = '\n'
            schedule = schedule_separator.join(schedule_items)

            dispatcher.utter_message(text=f"Our opening hours:\n{schedule}")
            return []

        # If there was no entry for given day of week string (most likely it was incorrect)
        if hours is None:
            dispatcher.utter_message(text=f"The day of week you provided is incorrect. Please try again.")
            return []

        # If user didn't provide exact hour or hour format is not valid display opening hours for given day
        if (hour == '') or (not represents_int(hour)):

            opening = hours.get('open')
            closing = hours.get('close')

            if (int(opening) == 0) and (int(closing) == 0):
                dispatcher.utter_message(text=f"On {day_of_week} the restaurant will be closed.")
            else:
                dispatcher.utter_message(text=f"On {day_of_week} the restaurant is open from {opening} to {closing}.")

            return []

        # If user provided incorrect hour
        if (int(hour) < 0) or (int(hour) > 24):
            dispatcher.utter_message(text=f"The hour you provided is incorrect. Please try again.")
            return []

        opening = hours.get('open')
        closing = hours.get('close')

        # Cover the case when restaurant is closed on given day
        if (int(opening) == 0) and (int(closing) == 0):
            dispatcher.utter_message(text=f"On {day_of_week} the restaurant will be closed.")
            return []

        # Finally, if all data was correct display opening hours for given day
        if (int(hour) >= int(opening)) and (int(hour) < int(closing)):
            dispatcher.utter_message(text=f"On {day_of_week} the restaurant is open at {hour}.")
        elif int(hour) < int(opening):
            dispatcher.utter_message(text=f"On {day_of_week} the restaurant will be open from {opening}.")
        else:
            dispatcher.utter_message(text=f"On {day_of_week} the restaurant will be closed from {closing}.")

        return []


class ActionDisplayMenu(Action):

    def name(self) -> Text:
        return 'action_display_menu'

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        # Fetch menu from file
        with open('restaurant_data/menu.json') as menu_file:
            menu = json.load(menu_file)

        menu_items = menu.get('items')
        formatted_menu = 'Our current menu:\n'

        # Iterate items available in menu and append them to formatted message
        for menu_item in menu_items:
            item_name = menu_item.get('name')
            item_price = menu_item.get('price')
            item_preparation_time = menu_item.get('preparation_time')
            formatted_menu += f"- {item_name}, price: {item_price}, preparation time: {item_preparation_time}\n"

        dispatcher.utter_message(text=formatted_menu)

        return []


class ActionSummarizeOrder(Action):

    def name(self) -> Text:
        return 'action_summarize_order'

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        # Obtain slot with ordered items and split it by item
        raw_order = tracker.get_slot('meals')
        order_items = raw_order.split(',')

        # Fetch menu from file
        with open('restaurant_data/menu.json') as menu_file:
            menu = json.load(menu_file)

        menu_items = menu.get('items')
        menu_items_names = []

        # Collect all menu items names to compare them with user requested names
        for menu_item in menu_items:
            menu_items_names.append(menu_item.get('name'))

        available_items = []
        unavailable_items = []
        exceeded_quantity_items = []
        summary_items = []
        summary_message = ''

        # Iterate user order and validate that item is available in menu
        for order_item in order_items:

            in_menu = 0

            # If order item string contains current menu item mark it as correct
            for menu_item_name in menu_items_names:
                if menu_item_name.lower() in order_item.lower():
                    in_menu = 1
                    break

            # Store correct and incorrect items in separate collections
            if in_menu == 0:
                unavailable_items.append(order_item)
            else:
                available_items.append(order_item)

        formatted_unavailable_items = []

        for unavailable_item in unavailable_items:

            # Remove trailing spaces and quantity from unavailable item string for proper displaying
            formatted_unavailable_item = ''.join([i for i in unavailable_item if not i.isdigit()]).lstrip()
            formatted_unavailable_items.append(formatted_unavailable_item)

        # Create message with unavailable items that user requested
        unavailable_items_separator = ", "
        failed_meals_for_user = unavailable_items_separator.join(formatted_unavailable_items)

        # If there are any unavailable items
        if unavailable_items:
            summary_message += f"Your order contains items that are not available in the menu.\n"
            summary_message += f"This items won't be included in your order: {failed_meals_for_user}\n"
            summary_message += f"---------------\n"

        total_price = 0
        total_time = 0

        # Calculate total cost and preparation time for items that are available
        for available_item in available_items:

            # Search for item quantity using regular expression
            search_result = re.search(r'\d+', available_item)

            # If nothing was found assume that one item was requested
            if search_result is None:
                quantity = 1
            else:
                quantity = int(search_result.group())

            current_menu_item = ''

            # Get the menu name of currently processed item
            for menu_item_name in menu_items_names:
                if menu_item_name.lower() in available_item.lower():
                    current_menu_item = menu_item_name

            # Remove item name from user request to obtain additional information
            raw_additional_information = available_item.lower().replace(current_menu_item.lower(), '')

            # Get additional information without quantity and remove trailing spaces
            additional_information = ''.join([i for i in raw_additional_information if not i.isdigit()]).lstrip()

            # Limit order quantity to 10 per item, if greater remove from order
            if quantity > 10:
                exceeded_quantity_summary = current_menu_item + ' ' + additional_information
                exceeded_quantity_items.append(exceeded_quantity_summary)
                continue

            current_item_price = 0
            current_item_time = 0

            # Get price and preparation time for currently processed item from menu
            for menu_item in menu_items:
                if menu_item.get('name') is current_menu_item:
                    current_item_price = menu_item.get('price')
                    current_item_time = menu_item.get('preparation_time')

            quantity_item_price_rounded = round(current_item_price * quantity,  2)
            quantity_item_time_rounded = round(current_item_time * quantity,  2)

            # Append data to total cost and total preparation time
            total_price = total_price + quantity_item_price_rounded
            # TODO: change preparation time calculations
            total_time = total_time + quantity_item_time_rounded

            # TODO: change preparation time calculations
            # Get summary for currently processed item
            available_item_summary = f"{quantity}x {current_menu_item}, price: {current_item_price}x{quantity}={quantity_item_price_rounded}, preparation time: {current_item_time}x{quantity}={quantity_item_time_rounded}"

            # If user provided any additional information for currently processed item include it in summary
            if additional_information:
                additional_information_summary = available_item_summary + f", additional information: {additional_information}\n"
                summary_items.append(additional_information_summary)
            else:
                summary_items.append(available_item_summary + f"\n")

        # Create message with items that exceed allowed quantity that user requested
        exceeded_quantity_separator = ", "
        exceeded_quantity_summary = exceeded_quantity_separator.join(exceeded_quantity_items)

        # If there are any items with exceeded quantity
        if exceeded_quantity_items:
            summary_message += f"Your order contains items with quantity greater than 10 which is a maximum for online orders.\n"
            summary_message += f"This items won't be included in your order: {exceeded_quantity_summary}\n"
            summary_message += f"---------------\n"

        # If at the end order contains any correct items
        if summary_items:
            for summary_item in summary_items:

                # Provide summary for each correct item
                summary_message += summary_item

            # TODO: change preparation time calculations
            # Provide total price and total preparation time
            summary_message += f"---------------\n"
            summary_message += f"Total price: {total_price}, your order will be delivered approximately after {total_time} hours.\n"
            summary_message += f"Do you prefer delivery to your place or pickup in the restaurant?"
            dispatcher.utter_message(text=summary_message)
        else:
            summary_message += f"We are sorry but after validation your order is empty. Please look at above issues and try again."
            dispatcher.utter_message(text=summary_message)

        return []


class ActionSummarizeDelivery(Action):

    def name(self) -> Text:
        return 'action_summarize_delivery'

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        # Obtain slot with delivery address
        order_address = tracker.get_slot('address')
        delivery_summary = f"Your order has been placed and will be delivered to {order_address}\n"
        delivery_summary += f"We will let you know when the order is dispatched."
        dispatcher.utter_message(text=delivery_summary)

        return []
