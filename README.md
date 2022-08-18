# PaymobAccept

`paymob_accept` is a Ruby gem created by [OneOrder](https://www.oneorder.net/) for integrating [Paymob](https://paymob.com/en) payment solutions with your Ruby application.

## Installation

Add this line to your appliciation's Gemfile:

```ruby
gem 'paymob_accept'
```

And then execute:

`$ bundle install`

Or install it yourself as:

`$ gem install paymob_accept`

## Usage

### Configuration

Configure the gem with your `api_key`

```ruby
PaymobAccept.configure do |config|
  config.api_key = YOUR_API_KEY
end
```

Optionally, you can pass the api_key to the constructor when initializing your payment service.

:bulb: You can get your API_KEY from Settings -> Account info -> API Key in your Paymob portal.

---

### Payment

- **Initialize your payment service**

  ```ruby
  service = PaymobAccept::Api::Pay.new(api_key: api_key)
  ```

- **Charging**

  ```ruby
  customer_data = {name:  "test",  email:  "test@test.com",  phone_number:  "01000000000"}
  address_data = {address_line1:  "10 street name", address_line2: "apt x. floor x",  region: "region", city: "Cairo", country: "EG"}
  service.charge(customer: customer_data, address: address_data, integration_id: 'xxxxx', method: :online, iframe_id: 'xxxxx', amount_cents: 1000, amount_currency: 'EGP', order_id: order_id)
  ```

  - If the `order_id` is not provided, an order is automatically created before attempting to charge.
  - The `method` key could be one of: 
    - :online => 3DS secure payment 
    - :kiosk => Kiosk payment
    - :cash => Cash on delivery
    - :auth => The "auth" component of auth/capture
    - :wallet => Vodafone cash
    - :moto => The "capture" component of auth/capture
  - The `charge` method's return value varies depedning on the `method`:
    - :online => if an `iframe_id` is provided, it returns an iframe url, otherwise a payment token
    - :kiosk => Paymob response body
    - :cash => Paymob response body
    - :auth => The "auth" component of auth/capture
    - :wallet => Vodafone cash
    - :moto => Paymob response body
  
- **Alternatively, you can you create a charge step by step**

  - **Step #1 Get auth_token**

    ```ruby
    token =  service.get_auth_token
    ```

  - **Step #2 Create_order**

    ```ruby
    service.create_order(auth_token: auth_token, amount_cents:  1000,  amount_currency:  'EGP', items:  [])
    ```

    `auth_token` is optional if not passed, it will be automatically generated.

    - Items are optional

      ```ruby
      items  =  [{
          "name":  "xxxxxxx-1",
          "amount_cents": "5000",
          "description": "Smart Watch",
          "quantity": "10"
      }]
      ```

  - **Step #3 Create payment key**

    ```ruby
    service.generate_payment_intent(customer: customer, address: address, integration_id: "xxxxx", amount_cents: amount_cents, amount_currency: "EGP", iframe_id: "xxxxxx", order_id: "xxxxxx")
    ```

## Dealing with charges

- **Initialize your Charge service**

  ```ruby
  service = PaymobAccept::Api::Charge.new(api_key: api_key)
  ```

- Retrieve transaction: `service.charge(transaction_id: transaction_id)`
- Refund transaction: `service.refund!(transaction_id: transaction_id, amount_cents: amount_cents)`
- Void a transaction: `service.void!(transaction_id: transaction_id)`

---

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/oneorder-tech/paymob).
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/oneorder-tech/paymob/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PaymobAccept project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/oneorder-tech/paymob/blob/master/CODE_OF_CONDUCT.md).
