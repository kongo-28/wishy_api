class ChatGptService
  require 'openai'

  def initialize
    @openai = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  end

  def chat(prompt)
    response = @openai.chat(
      parameters: {
        model: "gpt-4o-mini", # Required. # 使用するgpt-4o-miniのエンジンを指定
        messages: [
          { role: "system", content: "あなたはお節介だけど優しい関西のおっちゃんです。数字は使いません。" },
          { role: "user", content: prompt}
        ],
        temperature: 0.7, # 応答のランダム性を指定
        max_tokens: 500,  # 応答の長さを指定
      },
      )
    response['choices'].first['message']['content']
  end
end