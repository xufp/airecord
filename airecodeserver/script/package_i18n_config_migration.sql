-- 套餐多语言配置迁移脚本（基于t_app_config表）
-- 使用config_type = 8 存储套餐多语言配置

delete from ai_record_db.t_app_config where config_type = 8;
-- 中文套餐配置
INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
VALUES 
(8, 'package_10010001_zh', '{"package_name":"10小时转写","description":"含语音转写10小时，有效期1年"}', 'zh', '套餐多语言配置', 1),
(8, 'package_10010002_zh', '{"package_name":"30小时转写","description":"含语音转写30小时，有效期1年"}', 'zh', '套餐多语言配置', 1),
(8, 'package_10010003_zh', '{"package_name":"50小时转写","description":"含语音转写50小时，有效期1年"}', 'zh', '套餐多语言配置', 1),
(8, 'package_90010001_zh', '{"package_name":"新用户体验套餐包","description":"含语音转写1小时,有效期1年"}', 'zh', '套餐多语言配置', 1),
(8, 'package_90010002_zh', '{"package_name":"订阅计划-月卡","description":"含语音转写10小时,有效期30天"}', 'zh', '套餐多语言配置', 1),
(8, 'package_90010003_zh', '{"package_name":"激活卡套餐-年卡","description":"含语音转写1小时,有效期1年"}', 'zh', '套餐多语言配置', 1);

-- 英文套餐配置
INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
VALUES 
(8, 'package_10010001_en', '{"package_name":"10 Hours Transcription","description":"Includes 10 hours of speech transcription, valid for 1 year"}', 'en', 'Package I18n Config', 1),
(8, 'package_10010002_en', '{"package_name":"30 Hours Transcription","description":"Includes 30 hours of speech transcription, valid for 1 year"}', 'en', 'Package I18n Config', 1),
(8, 'package_10010003_en', '{"package_name":"50 Hours Transcription","description":"Includes 50 hours of speech transcription, valid for 1 year"}', 'en', 'Package I18n Config', 1),
(8, 'package_90010001_en', '{"package_name":"New User Experience Package","description":"Includes 1 hour of speech transcription, valid for 1 year"}', 'en', 'Package I18n Config', 1),
(8, 'package_90010002_en', '{"package_name":"Monthly Subscription Plan","description":"Includes 10 hour of speech transcription, valid for 30 days"}', 'en', 'Package I18n Config', 1),
(8, 'package_90010003_en', '{"package_name":"Activation Card Package - Annual","description":"Includes 1 hour of speech transcription, valid for 1 year"}', 'en', 'Package I18n Config', 1);

-- 日文套餐配置
INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
VALUES 
(8, 'package_10010001_ja', '{"package_name":"10時間転写","description":"音声転写10時間を含む、1年間有効"}', 'ja', 'Package I18n Config', 1),
(8, 'package_10010002_ja', '{"package_name":"30時間転写","description":"音声転写30時間を含む、1年間有効"}', 'ja', 'Package I18n Config', 1),
(8, 'package_10010003_ja', '{"package_name":"50時間転写","description":"音声転写50時間を含む、1年間有効"}', 'ja', 'Package I18n Config', 1),
(8, 'package_90010001_ja', '{"package_name":"新規ユーザー体験パッケージ","description":"音声転写1時間を含む、1年間有効"}', 'ja', 'Package I18n Config', 1),
(8, 'package_90010002_ja', '{"package_name":"月額サブスクリプションプラン","description":"音声転写10時間を含む、30日間有効"}', 'ja', 'Package I18n Config', 1),
(8, 'package_90010003_ja', '{"package_name":"アクティベーションカードパッケージ - 年額","description":"音声転写1時間を含む、1年間有効"}', 'ja', 'Package I18n Config', 1);

-- 韩文套餐配置
INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
VALUES 
(8, 'package_10010001_ko', '{"package_name":"10시간 전사","description":"음성 전사 10시간 포함, 1년 유효"}', 'ko', 'Package I18n Config', 1),
(8, 'package_10010002_ko', '{"package_name":"30시간 전사","description":"음성 전사 30시간 포함, 1년 유효"}', 'ko', 'Package I18n Config', 1),
(8, 'package_10010003_ko', '{"package_name":"50시간 전사","description":"음성 전사 50시간 포함, 1년 유효"}', 'ko', 'Package I18n Config', 1),
(8, 'package_90010001_ko', '{"package_name":"신규 사용자 체험 패키지","description":"음성 전사 1시간 포함, 1년 유효"}', 'ko', 'Package I18n Config', 1),
(8, 'package_90010002_ko', '{"package_name":"월간 구독 플랜","description":"음성 전사 10시간 포함, 30일 유효"}', 'ko', 'Package I18n Config', 1),
(8, 'package_90010003_ko', '{"package_name":"활성화 카드 패키지 - 연간","description":"음성 전사 1시간 포함, 1년 유효"}', 'ko', 'Package I18n Config', 1);
