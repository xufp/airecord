--
DROP DATABASE ai_record_db;
CREATE DATABASE ai_record_db;

DROP TABLE IF EXISTS ai_record_db.t_user_info;
CREATE TABLE ai_record_db.t_user_info (
    `user_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
    `nick_name` varchar(64) NOT NULL COMMENT '用户名称',
    `sex` int(11) NOT NULL DEFAULT 0 COMMENT '普通用户性别，1 为男性，2 为女性',
    `province` varchar(64) NOT NULL DEFAULT '' COMMENT '普通用户个人资料填写的省份',
    `city` varchar(64) NOT NULL DEFAULT '' COMMENT '普通用户个人资料填写的城市',
    `country` varchar(64) NOT NULL DEFAULT '' COMMENT '国家，如中国为 CN',
    `head_img_url` varchar(256) NOT NULL DEFAULT '' COMMENT '用户头像，最后一个数值代表正方形头像大小（有 0、46、64、96、132 数值可选，0 代表 640*640 正方形头像），用户没有头像时该项为空',
    `phone` varchar(64) COMMENT '电话号码',
    `email` varchar(256) COMMENT 'smtp',
    `password` varchar(128) NOT NULL DEFAULT '' COMMENT '密码',
    `state` int(11) NOT NULL DEFAULT 0 COMMENT '用户注册状态 1: 待绑定手机号(邮箱待验证)，2：注册成功, 3: 已注销',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`user_id`),
    UNIQUE KEY `idx_phone` (`phone`),
    UNIQUE KEY `idx_email` (`email`),
    KEY `idx_update_time` (`last_update_time`)
 ) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户信息表';

DROP TABLE IF EXISTS ai_record_db.t_third_auth;
CREATE TABLE ai_record_db.t_third_auth (
    `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    `channel` int(11) NOT NULL COMMENT '第三方渠道: 1: 微信',
    `user_id` bigint(20) NOT NULL COMMENT '用户ID',
    `union_id` varchar(64) NOT NULL DEFAULT '' COMMENT '用户统一标识。针对一个微信开放平台账号下的应用，同一用户的 union_id 是唯一的. App已获取用户信息授权时才有值',
    `openid` varchar(64) NOT NULL DEFAULT '' COMMENT '授权用户唯一标识',
    `access_token` varchar(512) NOT NULL DEFAULT '' COMMENT '接口调用凭证（有效期2小时）',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_openid` (`channel`, `openid`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_update_time` (`last_update_time`)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='第三方授权信息表';

DROP TABLE IF EXISTS ai_record_db.t_user_token;
CREATE TABLE ai_record_db.t_user_token (
    `token` varchar(64) NOT NULL COMMENT '用户token',
    `user_id` bigint(20) NOT NULL COMMENT '用户ID',
    `expire_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '过期时间',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`token`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_update_time` (`last_update_time`)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户token信息表';

DROP TABLE IF EXISTS ai_record_db.t_verify_code;
CREATE TABLE ai_record_db.t_verify_code (
   `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
   `scene` int(11) NOT NULL DEFAULT 0 COMMENT '验证码使用场景 1-用户登录，2-密码重置',
   `uni_key` varchar(256) NOT NULL DEFAULT '' COMMENT '电话号码/smtp',
   `code` varchar(32) NOT NULL COMMENT '验证码',
   `expire_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '过期时间',
   `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
   `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
   `state` int(32) NOT NULL DEFAULT 0 COMMENT '状态 0: 未使用, 1: 已被使用',
   PRIMARY KEY (`id`),
   KEY `idx_uni_key` (`uni_key`),
   KEY `idx_update_time` (`last_update_time`)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='验证码表';

DROP TABLE IF EXISTS ai_record_db.t_media_info;
CREATE TABLE ai_record_db.t_media_info (
    `media_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '音频ID',
    `user_id` bigint(20) NOT NULL COMMENT '用户ID',
    `media_name` varchar(256) NOT NULL DEFAULT '' COMMENT '音频名称（可修改）',
    `file_format` varchar(256) NOT NULL DEFAULT '' COMMENT '音频格式 wav, mp3, acc ... ',
    `file_size` bigint(20) NOT NULL DEFAULT 0 COMMENT '音频文件大小(单位：byte)',
    `file_sign` varchar(64) NOT NULL DEFAULT '' COMMENT '音频文件签名(sha256)',
    `record_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '音频文件创建时间/录音时间',
    `record_address` varchar(512) NOT NULL DEFAULT '' COMMENT '记录地址',
    `duration` bigint(20) NOT NULL DEFAULT 0 COMMENT '音频时长：单位毫秒',
    `media_url` varchar(256) NOT NULL DEFAULT '' COMMENT '音频文件url地址 (file://,cos://)',
    `state` int(11) NOT NULL DEFAULT 0 COMMENT '状态 0:初始化，1：文件已上传，2: 转写中，3：已转写，4：转写失败',
    `rec_time` datetime DEFAULT NULL COMMENT '音频识别成功时间',
    `summary` varchar(256) NOT NULL DEFAULT '' COMMENT '文件摘要(已转写文本内容)',
    `description` varchar(512) NOT NULL DEFAULT '' COMMENT '描述信息',
    `media_type` int(11) NOT NULL DEFAULT 0 COMMENT '音频类型 1：常规录音文件；2：速记录音文件',
    `device_id` varchar(256) NOT NULL DEFAULT 0 COMMENT '设备ID',
    `lstate` int(32) NOT NULL DEFAULT 0 COMMENT '逻辑状态(判断当前记录是否逻辑删除) 1: active, 2: deleted',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`media_id`),
--     UNIQUE KEY `idx_user_file` (`user_id`, `media_name`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_update_time` (`last_update_time`)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='音频信息表';

DROP TABLE IF EXISTS ai_record_db.t_media_rec;
CREATE TABLE ai_record_db.t_media_rec (
    `media_id` bigint(20) NOT NULL COMMENT '音频ID',
    `rec_form` int(11) NOT NULL  COMMENT 'Asr服务形式 1：录音文件极速识别，2：实时语音识别，3：录音文件识别',
    `engine_type` varchar(64) NOT NULL COMMENT '引擎模型类型(16k_zh：中文通用；16k_en：英语；)',
    `format` varchar(256) NOT NULL DEFAULT '' COMMENT '音频编码格式 wav, mp3, acc ... ',
    `object_name` varchar(256) NOT NULL DEFAULT '' COMMENT '音频文件对象名称（路径）',
    `state` int(11) NOT NULL DEFAULT 0 COMMENT '0： 等待中，1: 识别中，2：已完成， 3：识别失败',
    `memo` varchar(512) NOT NULL DEFAULT '' COMMENT '备注信息(失败错误信息等)',
    `task_id` varchar(32) NOT NULL DEFAULT '' COMMENT '识别请求任务ID',
    `request_id` varchar(64) NOT NULL DEFAULT '' COMMENT '请求ID，用于tcloud日志查询',
    `duration` bigint(20) NOT NULL DEFAULT 0 COMMENT '识别音频的时长：毫秒',
    `text` mediumtext NOT NULL COMMENT '已识别完整文本[加密]',
    `sentence_detail` mediumtext NOT NULL COMMENT '识别结果段落级别明细[加密]',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`media_id`),
    KEY `idx_update_time` (`last_update_time`)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='音频语音识别表';

DROP TABLE IF EXISTS ai_record_db.t_media_summary;
CREATE TABLE ai_record_db.t_media_summary (
    `summary_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '总结记录ID',
    `media_id` bigint(20) NOT NULL COMMENT '音频ID',
    `engine` varchar(64) NOT NULL COMMENT '大模型引擎(hunyuan: 腾讯混元, openai, ...)',
    `prompt` varchar(1024) NOT NULL default '' COMMENT '总结Prompt',
    `state` int(11) NOT NULL default 0 COMMENT '状态 0-等待中，1-总结中，2-已完成，3-总结失败',
    `memo` varchar(512) NOT NULL DEFAULT '' COMMENT '备注信息',
    `content_type` int(11) NOT NULL DEFAULT 0 COMMENT '总结内容类型 1-引擎生成内容，2-用户修改内容',
    `content` text NOT NULL COMMENT '总结内容[加密]',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`summary_id`),
    KEY `idx_media_id` (`media_id`),
    KEY `idx_update_time` (`last_update_time`)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='音频总结记录表';

DROP TABLE IF EXISTS ai_record_db.t_company_info;
CREATE TABLE ai_record_db.t_company_info (
    `company_id` varchar(64) NOT NULL COMMENT '公司ID',
    `company_name` varchar(256) NOT NULL DEFAULT '' COMMENT '公司名称',
    `company_address` varchar(512) NOT NULL DEFAULT '' COMMENT '公司地址',
    `legal_person` varchar(64) NOT NULL DEFAULT  '' COMMENT '法人姓名',
    `legal_telephone` varchar(64) NOT NULL DEFAULT  '' COMMENT '法人座机',
    `legal_mobile` varchar(64) NOT NULL DEFAULT  '' COMMENT '法人手机',
    `contact_person` varchar(64) NOT NULL DEFAULT  '' COMMENT '联系人姓名',
    `contact_telephone` varchar(64) NOT NULL DEFAULT  '' COMMENT '联系人座机',
    `contact_mobile` varchar(64) NOT NULL DEFAULT  '' COMMENT '联系人手机',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`company_id`),
    KEY `idx_update_time` (`last_update_time`)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='录音笔工厂信息';


DROP TABLE IF EXISTS ai_record_db.t_service;
CREATE TABLE ai_record_db.t_service (
    `service_id` int(11) NOT NULL COMMENT '服务ID',
    `service_type` int(11) NOT NULL COMMENT '服务类型 1：语音转写，',
    `service_name` varchar(64) NOT NULL DEFAULT '' COMMENT '服务名称',
    `description` varchar(256) NOT NULL DEFAULT  '' COMMENT '服务描述',
    `quantity` bigint(20) NOT NULL DEFAULT 0 COMMENT '服务量（时长：单位秒）',
    `price` bigint(20) NOT NULL DEFAULT 0 COMMENT '价格（单位：分）',
    `currency` varchar(8) NOT NULL DEFAULT '' COMMENT '币种(CNY/USD/HKD...)',
    `validity_days` int(11) NOT NULL DEFAULT 0 COMMENT '服务有效期天数',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`service_id`),
    KEY `idx_update_time` (`last_update_time`)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='服务信息表';

delete from ai_record_db.t_service;
-- 年卡
insert into ai_record_db.t_service (service_id, service_type, service_name, description, quantity, price, currency, validity_days, create_time, last_update_time)
    values (1001, 1, '1小时转写', '语音转写服务1小时，有效期1年', 3600, 100, 'USD', 360, now(), now());
insert into ai_record_db.t_service (service_id, service_type, service_name, description, quantity, price, currency, validity_days, create_time, last_update_time)
    values (1002, 1, '10小时转写', '语音转写服务10小时，有效期1年', 36000, 1000, 'USD', 360, now(), now());
insert into ai_record_db.t_service (service_id, service_type, service_name, description, quantity, price, currency, validity_days, create_time, last_update_time)
    values (1003, 1, '30小时转写', '语音转写服务30小时，有效期1年', 108000, 3000, 'USD', 360, now(), now());
insert into ai_record_db.t_service (service_id, service_type, service_name, description, quantity, price, currency, validity_days, create_time, last_update_time)
    values (1004, 1, '50小时转写', '语音转写服务50小时，有效期1年', 180000, 5000, 'USD', 360, now(), now());
-- 月卡
insert into ai_record_db.t_service (service_id, service_type, service_name, description, quantity, price, currency, validity_days, create_time, last_update_time)
    values (2001, 1, '10小时转写', '语音转写服务10小时，有效期1月', 36000, 1000, 'USD', 30, now(), now());

DROP TABLE IF EXISTS ai_record_db.t_package;
CREATE TABLE ai_record_db.t_package (
    `package_id` int(11) NOT NULL COMMENT '套餐ID',
    `package_type` int(11) NOT NULL COMMENT '套餐类型 1：可免费领取（每个用户限领一次）, 2：付费购买， 3：订阅计划，4：激活卡',
    `package_name` varchar(64) NOT NULL DEFAULT '' COMMENT '套餐名称',
    `description` varchar(256) NOT NULL DEFAULT  '' COMMENT '套餐描述',
    `price` bigint(20) NOT NULL DEFAULT 0 COMMENT '套餐总价',
    `rates` bigint(20) NOT NULL DEFAULT 0 COMMENT '套餐折扣率(%)',
    `currency` varchar(8) NOT NULL DEFAULT '' COMMENT '币种(CNY/USD/HKD...)',
    `begin_date` datetime NOT NULL COMMENT '套餐有效期-开始',
    `end_date` datetime NOT NULL COMMENT '套餐有效期-结束',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`package_id`),
    KEY `idx_update_time` (`last_update_time`)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='套餐信息表';

delete from ai_record_db.t_package;

insert into ai_record_db.t_package (package_id, package_type, package_name, description, price, rates, currency, begin_date, end_date, create_time, last_update_time)
    values (10010001, 2, '10小时转写', '含语音转写10小时，有效期1年', 500, 100, 'USD', '2024-07-01 00:00:00', '9999-12-31 00:00:00', now(), now());
insert into ai_record_db.t_package (package_id, package_type, package_name, description, price, rates, currency, begin_date, end_date, create_time, last_update_time)
    values (10010002, 2, '30小时转写', '含语音转写30小时，有效期1年', 1300, 100, 'USD', '2024-07-01 00:00:00', '9999-12-31 00:00:00', now(), now());
insert into ai_record_db.t_package (package_id, package_type, package_name, description, price, rates, currency, begin_date, end_date, create_time, last_update_time)
    values (10010003, 2, '50小时转写', '含语音转写50小时，有效期1年', 2000, 100, 'USD', '2024-07-01 00:00:00', '9999-12-31 00:00:00', now(), now());

insert into ai_record_db.t_package (package_id, package_type, package_name, description, price, rates, currency, begin_date, end_date, create_time, last_update_time)
    values (90010001, 1, '新用户体验套餐包', '含语音转写1小时,有效期1年', 100, 0, 'USD', '2024-07-01 00:00:00', '9999-12-31 00:00:00', now(), now());
insert into ai_record_db.t_package (package_id, package_type, package_name, description, price, rates, currency, begin_date, end_date, create_time, last_update_time)
    values (90010002, 3, '订阅计划-月卡', '含语音转写10小时,有效期30天', 500, 90, 'USD', '2024-07-01 00:00:00', '9999-12-31 00:00:00', now(), now());
insert into ai_record_db.t_package (package_id, package_type, package_name, description, price, rates, currency, begin_date, end_date, create_time, last_update_time)
    values (90010003, 4, '激活卡套餐-年卡', '含语音转写1小时,有效期1年', 100, 0, 'USD', '2024-07-01 00:00:00', '9999-12-31 00:00:00', now(), now());


DROP TABLE IF EXISTS ai_record_db.t_package_service;
CREATE TABLE ai_record_db.t_package_service (
    `package_id` int(11) NOT NULL COMMENT '套餐ID',
    `service_id` int(11) NOT NULL COMMENT '服务ID',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`package_id`, `service_id`),
    KEY `idx_update_time` (`last_update_time`)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='套餐-服务配置表';

delete from ai_record_db.t_package_service;
insert into ai_record_db.t_package_service (package_id, service_id, create_time, last_update_time)
    values (10010001, 1002, now(), now());
insert into ai_record_db.t_package_service (package_id, service_id, create_time, last_update_time)
    values (10010002, 1003, now(), now());
insert into ai_record_db.t_package_service (package_id, service_id, create_time, last_update_time)
    values (10010003, 1004, now(), now());

insert into ai_record_db.t_package_service (package_id, service_id, create_time, last_update_time)
    values (90010001, 1001, now(), now());
insert into ai_record_db.t_package_service (package_id, service_id, create_time, last_update_time)
    values (90010002, 2001, now(), now());
insert into ai_record_db.t_package_service (package_id, service_id, create_time, last_update_time)
    values (90010003, 1001, now(), now());

DROP TABLE IF EXISTS ai_record_db.t_user_package;
CREATE TABLE ai_record_db.t_user_package (
    `user_package_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    `user_id` bigint(20) NOT NULL COMMENT '用户ID',
    `package_id` int(11) NOT NULL COMMENT '套餐ID',
    `service_type` int(11) NOT NULL COMMENT '服务类型 1：语音转写，',
    `begin_date` datetime NOT NULL COMMENT '服务开始日期',
    `end_date` datetime NOT NULL COMMENT '服务结束日期',
    `quantity` bigint(20) NOT NULL COMMENT '服务量（时长：单位秒）',
    `order_id` varchar(64) NOT NULL DEFAULT '' COMMENT '订单号',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`user_package_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_update_time` (`last_update_time`)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户套餐表';

DROP TABLE IF EXISTS ai_record_db.t_user_cost;
CREATE TABLE ai_record_db.t_user_cost (
    `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    `user_id` bigint(20) NOT NULL COMMENT '用户ID',
    `service_type` int(11) NOT NULL COMMENT '服务类型',
    `user_package_id` bigint(20) NOT NULL COMMENT '用户套餐ID',
    `quantity_used` bigint(20) NOT NULL COMMENT '已使用量（时长：单位秒）',
    `quantity_canceled` bigint(20) NOT NULL COMMENT '已退回量（时长：单位秒）',
    `cost_date` varchar(20) DEFAULT '' COMMENT '使用日期',
    `description` varchar(256) NOT NULL DEFAULT  '' COMMENT '使用情况描述',
    `media_id` bigint(20) NOT NULL COMMENT '关联-音频ID',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_update_time` (`last_update_time`)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户使用记录表';

DROP TABLE IF EXISTS ai_record_db.t_order;
CREATE TABLE ai_record_db.t_order (
    `order_id` varchar(64) NOT NULL COMMENT '订单号',
    `user_id` bigint(20) NOT NULL COMMENT '用户ID',
    `package_id` int(11) NOT NULL COMMENT '套餐ID',
    `package_name` varchar(64) NOT NULL DEFAULT '' COMMENT '套餐名称',
    `state` int(11) NOT NULL COMMENT '订单状态 0：初始化，1：待支付，2：已支付成功，3：支付失败/撤销, ...',
    `amount` bigint(20) NOT NULL COMMENT '金额',
    `currency` varchar(8) NOT NULL DEFAULT '' COMMENT '币种(CNY/USD/HKD...)',
    `pay_time` datetime COMMENT '支付时间',
    `pay_channel` int(11) NOT NULL DEFAULT 0 COMMENT '支付渠道 1-paypal, 2-apple pay, 3-alipay, 4-wechat pay',
    `payment_type` int(11) NOT NULL DEFAULT 0 COMMENT '支付类型 1: 一次性支付, 2: 订阅支付',
    `payment_id` varchar(64) NOT NULL DEFAULT '' COMMENT '支付ID(类型=1：支付订单号，2-订阅ID)',
    `payment_desc` varchar(512) NOT NULL DEFAULT '' COMMENT '支付描述信息',
    `memo` varchar(512) NOT NULL DEFAULT '' COMMENT '备注信息',
    `lstate` int(32) NOT NULL DEFAULT 0 COMMENT '逻辑状态(判断当前记录是否逻辑删除) 1: active, 2: deleted',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`order_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_payment_idx` (`payment_id`),
    KEY `idx_update_time` (`last_update_time`)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='订单表';

DROP TABLE IF EXISTS ai_record_db.t_subscription_product;
CREATE TABLE ai_record_db.t_subscription_product (
    `product_id` varchar(64) NOT NULL COMMENT '产品ID',
    `product_name` varchar(64) NOT NULL DEFAULT '' COMMENT '产品名称',
    `product_desc` varchar(256) NOT NULL DEFAULT '' COMMENT '产品描述',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`product_id`),
    KEY `idx_update_time` (`last_update_time`)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='支付订阅产品表';

DROP TABLE IF EXISTS ai_record_db.t_subscription_plan;
CREATE TABLE ai_record_db.t_subscription_plan (
    `plan_id` varchar(64) NOT NULL COMMENT '订阅ID',
    `package_id` int(11) NOT NULL COMMENT '套餐ID',
    `product_id` varchar(64) NOT NULL DEFAULT '' COMMENT '产品ID',
    `plan_name` varchar(64) NOT NULL DEFAULT '' COMMENT '订阅名称',
    `description` varchar(256) NOT NULL DEFAULT '' COMMENT '订阅描述',
    `amount` bigint(20) NOT NULL COMMENT '金额',
    `currency` varchar(8) NOT NULL DEFAULT '' COMMENT '币种(CNY/USD/HKD...)',
    `interval` int(11) NOT NULL COMMENT '订阅计费间隔天数',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`plan_id`),
    Unique KEY `idx_package_id` (`package_id`),
    KEY `idx_update_time` (`last_update_time`)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='支付订阅计划表';

DROP TABLE IF EXISTS ai_record_db.t_subscription_deduct;
CREATE TABLE ai_record_db.t_subscription_deduct (
    `deduct_id` varchar(64) NOT NULL COMMENT '扣款ID',
    `subscription_id` varchar(64) NOT NULL COMMENT '订阅ID',
    `user_id` bigint(20) NOT NULL COMMENT '用户ID',
    `description` varchar(256) NOT NULL DEFAULT '' COMMENT '扣款描述',
    `state` int(11) NOT NULL COMMENT '扣款状态 1：扣款成功，2：扣款失败',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`deduct_id`),
    KEY `idx_subscription_id` (`subscription_id`),
    KEY `idx_update_time` (`last_update_time`)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='支付订阅扣款记录表';

DROP TABLE IF EXISTS ai_record_db.t_membership;
CREATE TABLE ai_record_db.t_membership (
    `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    `user_id` bigint(20) NOT NULL COMMENT '用户ID',
    `level` int(11) NOT NULL COMMENT '会员等级 0->2',
    `expire_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '过期时间',
    `state` int(11) NOT NULL COMMENT '状态 1：有效，2：无效(冻结)',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_user_level` (`user_id`, `level`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='会员表';

DROP TABLE IF EXISTS ai_record_db.t_activation_card;
CREATE TABLE ai_record_db.t_activation_card (
    `card_no` varchar(64) NOT NULL COMMENT '激活卡号',
    `card_pwd` varchar(128) NOT NULL COMMENT '激活卡密码',
    `card_state` int(11) NOT NULL COMMENT '激活卡状态 1：未激活，2：已激活, 3: 已作废',
    `card_order_id` varchar(64) NOT NULL DEFAULT '' COMMENT '激活卡订单号',
    `card_expire_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '激活卡过期时间',
    `activation_user_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '激活用户ID',
    `activation_time` datetime COMMENT '激活时间',
    `package_id` int(11) NOT NULL COMMENT '套餐ID',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`card_no`)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='激活卡表';

DROP TABLE IF EXISTS ai_record_db.t_user_feedback;
CREATE TABLE ai_record_db.t_user_feedback (
    `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    `user_id` bigint(20) NOT NULL COMMENT '用户ID',
    `content` varchar(4096) NOT NULL COMMENT '反馈内容',
    `contract` varchar(256) NOT NULL DEFAULT '' COMMENT '联系方式',
    `state` int(11) NOT NULL COMMENT '处理状态 1：未处理，2：已处理',
    `description` text NOT NULL COMMENT '描述信息',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户反馈表';

DROP TABLE IF EXISTS ai_record_db.t_app_config;
CREATE TABLE ai_record_db.t_app_config (
    `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    `config_type` int(11) NOT NULL COMMENT '配置类型 1-应用协议,2-帮助手册,3-IOS版本，4-Android版本,5...',
    `config_key` varchar(256) NOT NULL COMMENT '配置项key',
    `config_value` text NOT NULL COMMENT '配置项值',
    `config_desc` varchar(256) NOT NULL DEFAULT '' COMMENT '配置描述',
    `config_name` varchar(256) NOT NULL DEFAULT '' COMMENT '配置名称',
    `lstate` int(32) NOT NULL DEFAULT 0 COMMENT '逻辑状态(判断当前记录是否逻辑删除) 1: active, 2: deleted',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后修改时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_config_uid` (`config_type`, `config_key`)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='应用配置表';

INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
    values (1, 'user_agreement_zh', '用户协议内容', '', '用户协议', 1);
INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
    values (1, 'privacy_policy_zh', '隐式政策内容', '', '隐式政策', 1);
INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
    values (1, 'user_agreement_en', 'User Agreement Content', '', '用户协议', 1);
INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
    values (1, 'privacy_policy_en', 'Privacy Policy Content', '', '隐式政策', 1);

INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
    values (2, '如何激活会员？', '普通用户通过激活卡激活可得钻石会员，通过订阅服务可升级为Pro会员', 'zh', '帮助手册', 1);
INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
    values (2, '如何激活会员2？', '普通用户通过激活卡激活可得钻石会员，通过订阅服务可升级为Pro会员2', 'zh', '帮助手册', 1);
INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
    values (2, '如何激活会员3？', '普通用户通过激活卡激活可得钻石会员，通过订阅服务可升级为Pro会员3', 'zh', '帮助手册', 1);
INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
    values (2, 'How to activate membership？', 'Regular users can activate Diamond membership through an activation card, and can upgrade to Pro membership through a subscription service.', 'en', '帮助手册', 1);

INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
    values (3, 'v1.0.1', 'https://example.com/download/v1.0.1', '修复了若干BUG', 'IOS应用版本信息', 1);
INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
    values (4, 'v1.0.1', 'https://example.com/download/v1.0.1', '修复了若干BUG', 'Android应用版本信息', 1);

INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
    values (5, '16k_zh', '{"zh":"中文普通话","en":"chinese"}', '中文普通话', 'Asr引擎模型', 1);
INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
    values (5, '16k_en', '{"zh":"英语","en":"english"}', '英语', 'Asr引擎模型', 1);
INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
    values (5, '16k_yue', '{"zh":"粤语","en":"cantonese"}', '粤语', 'Asr引擎模型', 1);
INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
    values (5, '16k_zh-PY', '{"zh":"中英粤","en":"chinese, english and cantonese"}', '中英粤', 'Asr引擎模型', 1);
INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
    values (5, '16k_zh_dialect', '{"zh":"中文普通话+方言","en":"chinese + dialects"}', '中文普通话+方言', 'Asr引擎模型', 1);
INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
    values (5, '16k_ja', '{"zh":"日语","en":"japanese"}', '日语', 'Asr引擎模型', 1);
INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
    values (5, '16k_ko', '{"zh":"韩语","en":"korean"}', '韩语', 'Asr引擎模型', 1);

INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
    values (6, 'prompt_t1', '你是一名会议记录员，请对以下会议内容进行总结，生成会议纪要，请使用与会议内容相同的语言输出。会议内容如下：', '{"default":"会议总结","zh":"会议总结","en":"Meeting Summary"}', 'Prompt模版', 1);
INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
    values (6, 'prompt_t2', '你是一位阅读理解和文本总结专家。请仔细阅读以下录音转写文本内容，然后用该文本的语言对它进行简洁且清晰的总结。总结时要突出重点和关键信息，保证条理清晰，避免冗长和无关内容。\n\n【转写文本开始】\n{transcribed_text}\n【转写文本结束】\n\n请用与上面文本相同的语言输出总结。', '{"default":"通用模版","zh":"通用模版","en":"General Summary"}', 'Prompt模版', 1);

delete from ai_record_db.t_app_config where config_type = 7 and config_key = 'ble_device_01';
INSERT INTO ai_record_db.t_app_config (config_type, config_key, config_value, config_desc, config_name, lstate)
values (7, 'ble_device_01', '{"device_type":"BT_BLE","device_name":"BT_BLE","device_uuid":"ae30","device_image":"https://gitee.com/svenx/assets/raw/master/images/ble_device_01_bg.png","device_desc":"设备描述和操作描述","characteristic_write":"ae31","characteristic_notify":"ae32","characteristic_battery_notify":"ae33"}', '', '蓝牙设备', 1);
