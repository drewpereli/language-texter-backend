class CreateLanguages < ActiveRecord::Migration[6.1]
  def up
    create_table :languages do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.string :native_name, null: false
      t.timestamps
    end

    data = [
      { code: 'en', name: 'English', native_name: 'English' },
      { code: 'es', name: 'Spanish', native_name: 'español' },
      { code: 'am', name: 'Amharic', native_name: 'አማርኛ' },
      { code: 'ar', name: 'Arabic', native_name: 'العربية' },
      { code: 'eu', name: 'Basque', native_name: 'euskara, euskera' },
      { code: 'bn', name: 'Bengali', native_name: 'বাংলা' },
      { code: 'bg', name: 'Bulgarian', native_name: 'български език' },
      { code: 'ca', name: 'Catalan; Valencian', native_name: 'Català' },
      { code: 'zh', name: 'Chinese', native_name: '中文 (Zhōngwén), 汉语, 漢語' },
      { code: 'hr', name: 'Croatian', native_name: 'hrvatski' },
      { code: 'cs', name: 'Czech', native_name: 'česky, čeština' },
      { code: 'da', name: 'Danish', native_name: 'dansk' },
      { code: 'nl', name: 'Dutch', native_name: 'Nederlands, Vlaams' },
      { code: 'et', name: 'Estonian', native_name: 'eesti, eesti keel' },
      { code: 'fi', name: 'Finnish', native_name: 'suomi, suomen kieli' },
      { code: 'fr', name: 'French', native_name: 'français, langue française' },
      { code: 'de', name: 'German', native_name: 'Deutsch' },
      { code: 'el', name: 'Greek, Modern', native_name: 'Ελληνικά' },
      { code: 'gu', name: 'Gujarati', native_name: 'ગુજરાતી' },
      { code: 'hi', name: 'Hindi', native_name: 'हिन्दी, हिंदी' },
      { code: 'hu', name: 'Hungarian', native_name: 'Magyar' },
      { code: 'is', name: 'Icelandic', native_name: 'Íslenska' },
      { code: 'id', name: 'Indonesian', native_name: 'Bahasa Indonesia' },
      { code: 'it', name: 'Italian', native_name: 'Italiano' },
      { code: 'ja', name: 'Japanese', native_name: '日本語 (にほんご／にっぽんご)' },
      { code: 'kn', name: 'Kannada', native_name: 'ಕನ್ನಡ' },
      { code: 'ko', name: 'Korean', native_name: '한국어 (韓國語), 조선말 (朝鮮語)' },
      { code: 'lv', name: 'Latvian', native_name: 'latviešu valoda' },
      { code: 'lt', name: 'Lithuanian', native_name: 'lietuvių kalba' },
      { code: 'ms', name: 'Malay', native_name: 'bahasa Melayu, بهاس ملايو‎' },
      { code: 'ml', name: 'Malayalam', native_name: 'മലയാളം' },
      { code: 'mr', name: 'Marathi (Marāṭhī)', native_name: 'मराठी' },
      { code: 'no', name: 'Norwegian', native_name: 'Norsk' },
      { code: 'pl', name: 'Polish', native_name: 'polski' },
      { code: 'ro', name: 'Romanian, Moldavian, Moldovan', native_name: 'română' },
      { code: 'ru', name: 'Russian', native_name: 'русский язык' },
      { code: 'sr', name: 'Serbian', native_name: 'српски језик' },
      { code: 'sk', name: 'Slovak', native_name: 'slovenčina' },
      { code: 'sl', name: 'Slovene', native_name: 'slovenščina' },
      { code: 'sw', name: 'Swahili', native_name: 'Kiswahili' },
      { code: 'sv', name: 'Swedish', native_name: 'svenska' },
      { code: 'ta', name: 'Tamil', native_name: 'தமிழ்' },
      { code: 'te', name: 'Telugu', native_name: 'తెలుగు' },
      { code: 'th', name: 'Thai', native_name: 'ไทย' },
      { code: 'tr', name: 'Turkish', native_name: 'Türkçe' },
      { code: 'ur', name: 'Urdu', native_name: 'اردو' },
      { code: 'uk', name: 'Ukrainian', native_name: 'українська' },
      { code: 'vi', name: 'Vietnamese', native_name: 'Tiếng Việt' },
      { code: 'cy', name: 'Welsh', native_name: 'Cymraeg' },
    ]

    Language.create(data)
  end

  def down
    drop_table :languages
  end
end
