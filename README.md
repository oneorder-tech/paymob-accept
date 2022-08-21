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

Configure the gem with your configuration

```ruby
PaymobAccept.configure do |config|
	config.api_key = "######"
	config.online_integration_id = "######"
	config.kiosk_integration_id = "######"
	config.cash_integration_id = "######"
	config.wallet_integration_id = "######"
	config.auth_integration_id = "######"
	config.moto_integration_id = "######"
end
```

Optionally, any configuration parameters mentioned above could be passed to the constructor when initializing the payment service.

:bulb: You can get your API_KEY from Settings -> Account info -> API Key in your Paymob portal.

For reference on the internals & specifics of Paymob, please head to their official documentation [here](https://docs.paymob.com/)

## Creating a charge:

1. Initialize your payment service

    ```ruby
    service = PaymobAccept::Api::Pay.new(api_key: api_key, online_integration_id: "12345678")
    ```

2. Prepare your customer data using the following schemas (All fields are required):

    ```ruby
      customer_data = {name:  "test",  email:  "test@test.com",  phone_number:  "01000000000"}
      billing_address_data = {address_line1:  "10 street name", address_line2: "apt x. floor x",  region: "region", city: "Cairo", country: "EG"}
    ```
3. Create a charge:

    ```ruby
    service.charge(customer: customer_data, address: billing_address_data, method: :online, iframe_id: 'xxxxx', amount_cents: 1000)
    ```

Note. All integration id methods are public and could so it could be easily used to set an integration as:

```ruby
service.online_integration_id = "123"
```

### Alternatively, you can you create a charge step by step (Not recommended):

1. Authentication request

    ```ruby
    token = service.get_auth_token
    ```

2.  Create_order
    ```ruby
    service.create_order(auth_token: token, amount_cents:  1000,  amount_currency:  'EGP', items:  [])
    ```

    - Items are optional

      ```ruby
      items  =  [{
          "name":  "xxxxxxx-1",
          "amount_cents": "5000",
          "description": "Smart Watch",
          "quantity": "10"
      }]
      ```

3. Create payment key

    ```ruby
    service.generate_payment_intent(customer: customer, address: address, integration_id: "xxxxx", amount_cents: amount_cents, amount_currency: "EGP", iframe_id: "xxxxxx", order_id: "xxxxxx")
    ```

## Supported payment methods

The `:method` key in the `charge` method could be one of the following:

- :online => 3D Secure payments with external redirection
- :auth => Auth/Capture payments
- :kiosk => Aman/Masary kiosk network
- :cash => Cash on delivery
- :wallet => Vodafone cash
- :moto => Paying with a saved token

Please refer to the official Paymob documentation for in-depth explanation about each payment method.

The return value of the `charge` method in general is the response of Paymob's server which varies according to the payment method except in `:online`. In an `:online` payment if an `iframe_id` is provided, the return value is an iFrame URL with an embedded payment token. If the `iframe_id` is not provided, only the payment token is returned

## Dealing with charges

- **Initialize your Charge service**

  ```ruby
  service = PaymobAccept::Api::Charge.new
  ```

- Retrieve transaction: `service.charge(transaction_id: transaction_id)`
- Refund transaction: `service.refund!(transaction_id: transaction_id, amount_cents: amount_cents)`
- Void a transaction: `service.void!(transaction_id: transaction_id)`
- Capture an auth transaction: `service.capture!(transaction_id: transaction_id, amount_cents: amount_cents)`


## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/oneorder-tech/paymob).
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/oneorder-tech/paymob/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PaymobAccept project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/oneorder-tech/paymob/blob/master/CODE_OF_CONDUCT.md).
