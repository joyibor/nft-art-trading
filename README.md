# NFT Art Trading Smart Contract

## Project Description
`nft-art-trading` is a Clarity smart contract designed for an artwork marketplace where artists can list and sell their artworks as NFTs. This contract enables artists to set prices, manage their artwork inventory, and ensures that royalty payments and platform fees are calculated automatically. It includes features for managing artwork quantities, setting royalty rates, adjusting platform fees, and ensuring secure transactions within a controlled environment.

The contract allows for administrative control over critical functions, such as modifying artwork prices, setting royalty rates, and defining limits on artwork quantities. It also maintains a reserve of artworks and ensures the marketplace operates efficiently by tracking sales and purchases.

## Features
- **Artist Management**: Artists can list their artworks, specify prices, and control quantities.
- **Royalty and Fee Calculation**: Automatically calculates royalties for artists and platform fees for the marketplace.
- **Admin Controls**: Administrators have control over artwork prices, royalties, and platform fees.
- **Artwork Reserve Management**: Keeps track of total artwork reserves and limits the number of artworks.
- **Transaction Management**: Ensures safe purchases and sales with checks for sufficient balance, and prevents duplicate transactions.

## Installation
To deploy this contract, you will need to have the following:
- A Clarity-compatible blockchain (e.g., Stacks).
- An environment that supports the Clarity language and smart contract execution.

1. Clone this repository:
    ```bash
    git clone https://github.com/your-username/nft-art-trading.git
    cd nft-art-trading
    ```

2. Deploy the contract to your Clarity-compatible blockchain using the appropriate tools for your environment. Make sure to use the relevant CLI tools or deploy scripts.

## Usage
Once deployed, this contract provides various functions for artists, users, and admins to interact with the marketplace.

### Public Functions
- `set-art-price`: Sets the price per artwork (admin only).
- `set-royalty-rate`: Sets the royalty percentage for artists (admin only).
- `set-max-art-per-artist`: Sets the maximum number of artworks an artist can list (admin only).
- `add-artwork-listing`: Allows artists to list their artworks for sale.
- `purchase-artwork`: Users can purchase artwork, which triggers royalty payments and platform fees.
- `remove-artwork`: Artists can remove their artwork from the marketplace.

### Read-Only Functions
- `get-art-price`: Returns the current price per artwork.
- `get-royalty-rate`: Returns the current royalty rate for artworks.
- `get-platform-fee-rate`: Returns the platform fee rate.
- `get-artist-balance`: Returns the balance of artworks an artist has available.
- `get-artwork-for-sale`: Returns the quantity and price of an artist's artworks for sale.

## Contract Functions

### Admin Functions
- **Set Artwork Price**: Allows the admin to set the price for artworks.
- **Set Royalty Rate**: Allows the admin to set the royalty rate for artists.
- **Set Platform Fee Rate**: Allows the admin to set the platform fee rate.

### Artist Functions
- **Add Artwork Listing**: Artists can list new artworks for sale, setting the price and quantity.
- **Remove Artwork**: Artists can remove artwork from the marketplace.
- **Purchase Artwork**: Users can purchase artwork, triggering royalty and fee payments.

### Calculation Functions
- **Royalty Calculation**: Calculates the royalty for an artwork sale.
- **Platform Fee Calculation**: Calculates the platform fee for an artwork sale.

## Example Use Cases

### Add New Artwork for Sale
```clarity
(add-artwork-listing 10 5000)
```
This command lists 10 artworks for sale, each priced at 5000 microstacks.

### Purchase Artwork
```clarity
(purchase-artwork 'artist-principal 2)
```
This command purchases 2 artworks from the artist identified by `artist-principal`.

### View Artist's Balance
```clarity
(get-artist-balance 'artist-principal)
```
This command retrieves the balance of artworks available for sale by the artist.

## Error Handling
The contract includes error messages for various conditions:
- `err-admin-only`: Triggered if a non-admin user attempts to access admin-only functions.
- `err-insufficient-balance`: Triggered if an artist or user does not have enough balance to complete a transaction.
- `err-invalid-art-price`: Triggered if an invalid artwork price is provided.
- `err-transfer-failed`: Triggered if a transfer operation fails.
- `err-ownership-failed`: Triggered if ownership transfer fails.
- `err-duplicate-transaction`: Triggered if a duplicate transaction is detected.
- `err-reserve-limit-surpassed`: Triggered if the artwork reserve limit is exceeded.

## Contributing
Contributions are welcome! To contribute, please fork this repository, make your changes, and submit a pull request. Ensure that your code adheres to the coding style and passes all tests.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
