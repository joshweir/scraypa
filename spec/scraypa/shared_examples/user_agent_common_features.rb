def expect_common_aliases_and_changes_after_n_requests params
  Scraypa.reset
  configure_scraypa(
      (params || {}).merge({
                       user_agent: {
                           strategy: :randomize,
                           change_after_n_requests: 2
                       }
                   }))
  Scraypa.visit method: :get, url: "http://example.com/"
  common_agents = Scraypa::USER_AGENT_LIST.values
  agent_before = Scraypa.user_agent
  expect(agent_before).to_not be_nil
  expect(common_agents).to include agent_before
  Scraypa.visit method: :get, url: "http://example.com/"
  expect(Scraypa.user_agent).to eq agent_before
  Scraypa.visit method: :get, url: "http://example.com/"
  agent_after = Scraypa.user_agent
  expect(agent_after).to_not eq agent_before
  expect(common_agents).to include agent_after
end