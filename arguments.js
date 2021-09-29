require('dotenv').config()

const treasuryShares = [
    process.env.TREASURY_SHARES_1,
    process.env.TREASURY_SHARES_2,
    process.env.TREASURY_SHARES_3,
    process.env.TREASURY_SHARES_4,
    process.env.TREASURY_SHARES_5,
    process.env.TREASURY_SHARES_6,
    process.env.TREASURY_SHARES_7,
    process.env.TREASURY_SHARES_8,
];
const treasuryWallets = [
    process.env.TREASURY_WALLET_1,
    process.env.TREASURY_WALLET_2,
    process.env.TREASURY_WALLET_3,
    process.env.TREASURY_WALLET_4,
    process.env.TREASURY_WALLET_5,
    process.env.TREASURY_WALLET_6,
    process.env.TREASURY_WALLET_7,
    process.env.TREASURY_WALLET_8,
];

module.exports = [
    treasuryWallets,
    treasuryShares
]