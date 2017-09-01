def expect_common_aliases_and_changes_after_n_requests params
  Scraypa.reset
  configure_scraypa(
      (params || {}).merge({
                       user_agent: {
                           strategy: :randomize,
                           change_after_n_requests: 2
                       }
                   }))
  Scraypa.visit method: :get, url: "http://bot.whatismyipaddress.com/"
  common_agents = Scraypa::USER_AGENT_LIST.values
  agent_before = Scraypa.user_agent
  expect(agent_before).to_not be_nil
  expect(common_agents).to include agent_before
  Scraypa.visit method: :get, url: "http://bot.whatismyipaddress.com/"
  expect(Scraypa.user_agent).to eq agent_before
  Scraypa.visit method: :get, url: "http://bot.whatismyipaddress.com/"
  agent_after = Scraypa.user_agent
  expect(agent_after).to_not eq agent_before
  expect(common_agents).to include agent_after
end

def expect_common_aliases_random params
  Scraypa.reset
  configure_scraypa (params || {})
                        .merge({user_agent: {
                            strategy: :randomize
                        }})
  common_agents = Scraypa::USER_AGENT_LIST.values
  user_agents = []
  3.times do
    Scraypa.visit method: :get, url: "http://bot.whatismyipaddress.com/"
    user_agents << Scraypa.user_agent
  end
  expect(user_agents).to_not eq common_agents[0..2]
  user_agents.each do |user_agent|
    expect(common_agents).to include user_agent
  end
  expect(user_agents.uniq).to eq user_agents
end

def expect_common_aliases_round_robin params
  Scraypa.reset
  configure_scraypa (params || {})
                        .merge({user_agent: {
                            strategy: :round_robin
                        }})
  common_agents = Scraypa::USER_AGENT_LIST.values
  user_agents = []
  3.times do
    Scraypa.visit method: :get, url: "http://bot.whatismyipaddress.com/"
    user_agents << Scraypa.user_agent
  end
  expect(user_agents).to eq common_agents[0..2]
  expect(user_agents.uniq).to eq user_agents
end

def expect_ua_randomizer params
  Scraypa.reset
  configure_scraypa (params || {})
                        .merge({user_agent: {
                            method: :randomizer
                        }})
  common_agents = Scraypa::USER_AGENT_LIST.values
  user_agents = []
  2.times do
    Scraypa.visit method: :get, url: "http://bot.whatismyipaddress.com/"
    user_agents << Scraypa.user_agent
  end
  expect(common_agents).to_not include *user_agents
  expect(user_agents.uniq).to eq user_agents
end

def expect_ua_randomizer_list_limit params
  Scraypa.reset
  configure_scraypa (params || {})
                        .merge({user_agent: {
                            method: :randomizer,
                            list_limit: 2
                        }})
  common_agents = Scraypa::USER_AGENT_LIST.values
  user_agents = []
  3.times do
    Scraypa.visit method: :get, url: "http://bot.whatismyipaddress.com/"
    user_agents << Scraypa.user_agent
  end
  expect(common_agents).to_not include *user_agents
  expect(user_agents[0]).to eq user_agents[2]
  expect(user_agents[1]).to_not eq user_agents[0]
end

def expect_ua_list_random params
  Scraypa.reset
  configure_scraypa (params || {})
                        .merge({user_agent: {
                            list: %w(agent3 agent4 agent5),
                            strategy: :randomize
                        }})
  user_agents = []
  4.times do
    Scraypa.visit method: :get, url: "http://bot.whatismyipaddress.com/"
    user_agents << Scraypa.user_agent
  end
  expect(user_agents).to_not eq %w(agent3 agent4 agent5 agent3)
  expect(%w(agent3 agent4 agent5)).to include *(user_agents.uniq)
end

def expect_ua_list_round_robin params
  Scraypa.reset
  configure_scraypa (params || {})
                        .merge({user_agent: {
                            list: %w(agent3 agent4),
                            strategy: :round_robin
                        }})
  user_agents = []
  3.times do
    Scraypa.visit method: :get, url: "http://bot.whatismyipaddress.com/"
    user_agents << Scraypa.user_agent
  end
  expect(user_agents).to eq %w(agent3 agent4 agent3)
end

def expect_ua_list_random_list_limit params
  Scraypa.reset
  configure_scraypa (params || {})
                        .merge({user_agent: {
                            list: %w(agent3 agent4 agent5),
                            strategy: :randomize,
                            list_limit: 2
                        }})
  user_agents = []
  4.times do
    Scraypa.visit method: :get, url: "http://bot.whatismyipaddress.com/"
    user_agents << Scraypa.user_agent
  end
  expect(user_agents).to_not eq %w(agent3 agent4 agent5 agent3)
  expect(%w(agent3 agent4 agent5)).to include *(user_agents.uniq)
  expect(user_agents[0]).to eq user_agents[2]
  expect(user_agents[1]).to eq user_agents[3]
end

def expect_ua_list_round_robin_list_limit params
  Scraypa.reset
  configure_scraypa (params || {})
                        .merge({user_agent: {
                            list: %w(agent8 agent9 agent10),
                            strategy: :round_robin,
                            list_limit: 2
                        }})
  user_agents = []
  3.times do
    Scraypa.visit method: :get, url: "http://bot.whatismyipaddress.com/"
    user_agents << Scraypa.user_agent
  end
  expect(user_agents).to eq %w(agent8 agent9 agent8)
end

