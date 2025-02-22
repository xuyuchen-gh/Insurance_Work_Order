-- 1. 退保率计算
-- 假设数据存储在两张表中：life_health_reserve表存储期初寿险和长期健康险责任准备金，包含字段beginning_life_reserve（期初寿险责任准备金）、beginning_health_reserve（期初长期健康险责任准备金）；
-- premium_surrender表存储报告期长期险原/分保费收入和报告期退保金，包含字段report_period_premium（报告期长期险原/分保费收入）、report_period_surrender（报告期退保金）
SELECT
    -- 计算退保率，公式：报告期退保金÷(期初长期险责任准备金 + 报告期长期险原/分保费收入)×100%
    -- 其中，期初长期险责任准备金 = 期初寿险责任准备金 + 期初长期健康险责任准备金
    report_period_surrender / (beginning_life_reserve + beginning_health_reserve + report_period_premium) * 100 AS surrender_rate
FROM
    life_health_reserve
JOIN
    premium_surrender;

-- 2. 未决赔款准备金与赔款支出比计算
-- 假设数据存储在claims表中，包含字段withdrawn_claim_reserve（提取未决赔款准备金）、reimbursed_claim_reserve（摊回未决赔款准备金）、claim_payment（赔付支出）、reimbursed_claim_payment（摊回赔付支出）
SELECT
    -- 计算未决赔款准备金与赔款支出比，公式：(提取未决赔款准备金 - 摊回未决赔款准备金)÷(赔付支出 - 摊回赔付支出)×100%
    (withdrawn_claim_reserve - reimbursed_claim_reserve) / (claim_payment - reimbursed_claim_payment) * 100 AS outstanding_claim_ratio
FROM
    claims;

-- 3. 已付赔款赔付率(业务年度)计算
-- 假设数据存储在两个表中：paid_claims表存储业务年度已付赔款，包含字段business_year_paid_claims（业务年度已付赔款）；
-- earned_premiums表存储业务年度已赚保费，包含字段business_year_earned_premiums（业务年度已赚保费）
SELECT
    -- 计算已付赔款赔付率(业务年度)，公式：业务年度已付赔款÷业务年度已赚保费×100%
    business_year_paid_claims / business_year_earned_premiums * 100 AS paid_claim_payout_ratio
FROM
    paid_claims
JOIN
    earned_premiums;

-- 4. 已报告赔款赔付率(业务年度)计算
-- 假设数据存储在三个表中：settled_claims表存储业务年度已决赔款，包含字段business_year_settled_claims（业务年度已决赔款）；
-- reported_unsettled_claims表存储业务年度已发生已报告未决赔款准备金，包含字段business_year_reported_unsettled_reserve（业务年度已发生已报告未决赔款准备金）；
-- earned_premiums表存储业务年度已赚保费，包含字段business_year_earned_premiums（业务年度已赚保费）
SELECT
    -- 计算已报告赔款赔付率(业务年度)，公式：(业务年度已决赔款 + 业务年度已发生已报告未决赔款准备金)÷业务年度已赚保费×100%
    (business_year_settled_claims + business_year_reported_unsettled_reserve) / business_year_earned_premiums * 100 AS reported_claim_payout_ratio
FROM
    settled_claims
JOIN
    reported_unsettled_claims ON settled_claims.business_year = reported_unsettled_claims.business_year
JOIN
    earned_premiums ON settled_claims.business_year = earned_premiums.business_year;