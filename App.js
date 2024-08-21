import { useState, useEffect } from "react";
import React from "react";
import Web3 from "web3";
import detectEthereumProvider from "@metamask/detect-provider";
import { loadContract } from "./utils/load-contract";
import "./App.css";

function App() {
  const [web3Api, setWeb3Api] = useState({
    // We create the variable with null values.
    // provider is the object that metamask send to each website and help to connect to metamask
    provider: null,
    web3: null,
    contract: null,
  });
  const [address, setAddress] = useState("");
  const [balance, setBalance] = useState(null);
  const [account, setAccount] = useState(null);
  const [deposit, setDeposit] = useState("");
  const [withdrawAmout, setWithdrawAmout] = useState("");

  function handlerDeposit(e) {
    setDeposit(e.target.value);
  }
  function handlerWithdraw(e) {
    setWithdrawAmout(e.target.value);
  }

  useEffect(() => {
    const loadProvider = async () => {
      // The function 'detectEthereumProvider' is detecting the metamask account provider.
      const provider = await detectEthereumProvider();
      // We define the contract and use the loadContract function
      const contract = await loadContract("Simplebank", provider);

      // We check if the provider is not empty (got a response)
      if (provider) {
        setWeb3Api({
          // we update the value of the metamask variables.
          provider: provider,
          web3: new Web3(provider),
          contract: contract,
        });
      } else {
        console.log("Please install Metamask");
      }
    };
    loadProvider();
  }, []);

  useEffect(() => {
    const loadBalance = async () => {
      const { contract, web3 } = web3Api;
      const balance = await web3.eth.getBalance(contract.address);
      setBalance(web3.utils.fromWei(balance, "ether"));
      setAddress(contract.address);
    };
    web3Api.contract && loadBalance();
  }, [web3Api]);

  useEffect(() => {
    const getAccount = async () => {
      const accounts = await web3Api.web3.eth.getAccounts();
      setAccount(accounts[0]);
    };
    web3Api.web3 && getAccount();
  }, [web3Api.web3]);

  // const addFunds = async () => {
  //   const { contract, web3 } = web3Api;
  //   await contract.addFunds({
  //     from: account,
  //     value: web3.utils.toWei(deposit, "ether"),
  //   });
  // };

  // const withdraw = async () => {
  //   console.log("pushed");
  //   const { contract, web3 } = web3Api;
  //   const withdrawAmount = web3.utils.toWei(withdrawAmout, "ether");
  //   await contract.withdraw(withdrawAmount, { from: account });
  // };
  const connect = async () => {
    const accounts = await window.ethereum.request({
      method: "eth_requestAccounts",
    });
    console.log(accounts);
  };

  return (
    <div className="App">
      <button onClick={connect}>Connect to Metamask</button>
    </div>
  );
}

export default App;
