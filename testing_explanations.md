#Testing Explanations

The tests written are to test the 'happy path' of the marketplace implementation (if users act exactly specified like the user stories). It test if there the owner is automatically given admin status.
Then the admin can add a store owner who can add storefronts and products. Then anyone is allowed to buy a product. The store balance is tested if it will
increase when the product is purchased and if the buyer's account balance decreases the correct amount.

For future improvements, more edge cases should be tested and to see if exceptions are thrown when require statements are not met. Tests should also be written with the expectation that there may be malicious users.
