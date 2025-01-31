import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure can register deployment for valid app",
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
      ),
      Tx.contractCall(
        "app-registry",
        "register-deployment",
        [
          types.uint(1),
          types.ascii("testnet"),
          types.principal(wallet_1.address),
          types.ascii("1.0.0")
        ],
        wallet_1.address
      )
    ]);
    
    assertEquals(block.receipts[1].result.expectOk(), true);
  }
});
