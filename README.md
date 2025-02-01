# Event Ticketing Smart Contract

## Overview

This Clarity smart contract enables a decentralized event ticketing system on the Stacks blockchain. It allows event organizers to mint tickets, users to purchase and transfer tickets, and ticket sellers to withdraw funds securely.

## Features

- **Mint Tickets**: Only the event organizer can create tickets.
- **Buy Tickets**: Users can purchase tickets with STX.
- **Transfer Tickets**: Ticket holders can transfer ownership.
- **Withdraw Funds**: Organizers can withdraw ticket sales revenue.

## Smart Contract Functions

1. `mint-ticket(ticket-id, price)`: Creates a new ticket.
2. `buy-ticket(ticket-id)`: Purchases a ticket and updates ownership.
3. `transfer-ticket(ticket-id, recipient)`: Transfers a ticket to another user.
4. `withdraw-funds()`: Withdraws balance from ticket sales.

## Deployment

Deploy this contract using Clarity and interact with it via a Stacks-compatible wallet or script.
