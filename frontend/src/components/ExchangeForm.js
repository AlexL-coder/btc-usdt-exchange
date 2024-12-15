import { ethers } from "ethers";
import { CONTRACT_ADDRESS, ABI } from "../config";

const provider = new ethers.providers.Web3Provider(window.ethereum);
const signer = provider.getSigner();
const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

function ExchangeForm() {
    const handleExchange = async (btcAmount) => {
        const tx = await contract.exchangeBTCToUSDT(ethers.utils.parseUnits(btcAmount, 8), {
            value: ethers.utils.parseUnits(btcAmount, 8),
        });
        await tx.wait();
        alert("Exchange successful!");
    };

    return (
        <form onSubmit={(e) => {
            e.preventDefault();
            const btcAmount = e.target.elements.btcAmount.value;
            handleExchange(btcAmount);
        }}>
            <input type="text" name="btcAmount" placeholder="BTC Amount" />
            <button type="submit">Exchange BTC to USDT</button>
        </form>
    );
}

export default ExchangeForm;
