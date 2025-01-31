import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure can create new app",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "core-forge",
        "create-app",
        [
          types.ascii("My App"),
          types.utf8("App description")
        ],
        wallet_1.address
      )
    ]);
    
    assertEquals(block.receipts[0].result.expectOk(), "u1");
  }
});

Clarinet.test({
  name: "Ensure only owner can update app status",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    const wallet_2 = accounts.get("wallet_2")!;
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "core-forge", 
        "create-app",
        [
          types.ascii("My App"),
          types.utf8("App description")
        ],
        wallet_1.address
      ),
      Tx.contractCall(
        "core-forge",
        "update-app-status",
        [
          types.uint(1),
          types.ascii("inactive")
        ],
        wallet_2.address
      )
    ]);
    
    assertEquals(block.receipts[1].result.expectErr(), "u100");
  }
});
