# my-duckdb-analytics

問診票アプリのデータを題材に、DuckDB・dbt・Lightdash を用いて構築した分析基盤プロジェクトです。

本プロジェクトでは、アプリケーションで蓄積されたユーザー情報・問診票回答データをもとに、データの整形、集計、モデリング、BI 可視化までの一連の流れを実装しています。

## Overview

このプロジェクトの目的は、単なるデータ抽出ではなく、アプリケーションデータを分析しやすい形に整え、意思決定やサービス改善に活用できるデータ基盤を構築することです。

主に以下の観点を重視しています。

- アプリケーションDB由来のデータを分析用に整形
- staging / intermediate / marts のレイヤー分割
- dbt によるデータ変換処理の管理
- DuckDB を用いたローカル分析環境の構築
- Lightdash によるメトリクス定義・可視化
- データエンジニアリングの学習・検証環境としての活用

## Tech Stack

| Category | Tools |
| --- | --- |
| Data Warehouse / OLAP | DuckDB |
| Transformation | dbt |
| BI / Visualization | Lightdash |
| Language | SQL, YAML |
| Development | VS Code |
| Version Control | Git / GitHub |

## Project Structure

```text
dbt_duckdb_project/
├── analyses/
├── logs/
├── macros/
│   └── generate_schema_name.sql
├── models/
│   ├── staging/
│   │   ├── metadata/
│   │   ├── stg_users.sql
│   │   ├── stg_medical_diagnosis_form.sql
│   │   └── stg_sources.yml
│   │
│   ├── intermediate/
│   │   ├── metadata/
│   │   │   ├── int_medical_diagnoses_enriched.yml
│   │   │   ├── int_medical_diagnoses_summary.yml
│   │   │   ├── int_patient_visit_cycles.yml
│   │   │   └── int_symptom_progression.yml
│   │   ├── int_medical_diagnoses_enriched.sql
│   │   ├── int_medical_diagnoses_summary.sql
│   │   ├── int_patient_visit_cycles.sql
│   │   └── int_symptom_progression.sql
│   │
│   └── marts/
│       ├── metadata/
│       │   ├── dim_patient_progression.yml
│       │   ├── dim_patients.yml
│       │   └── fct_diagnosis_events.yml
│       ├── dim_patient_progression.sql
│       ├── dim_patients.sql
│       └── fct_diagnosis_events.sql
```

## Data Modeling

本プロジェクトでは、dbt のモデルを以下の3層に分けて設計しています。

### 1. Staging Layer

アプリケーション由来の生データを、分析しやすい形に整える層です。

主なモデル：

- `stg_users`
- `stg_medical_diagnosis_form`

この層では、カラム名の整理、型変換、不要データの除外など、後続処理のための前処理を行います。

### 2. Intermediate Layer

staging のデータをもとに、分析に必要な中間集計や意味づけを行う層です。

主なモデル：

- `int_medical_diagnoses_enriched`
- `int_medical_diagnoses_summary`
- `int_patient_visit_cycles`
- `int_symptom_progression`

この層では、問診票回答データとユーザー情報の結合、症状の変化、来院・利用サイクル、診断イベントの整理などを行います。

### 3. Marts Layer

BI や分析にそのまま利用できる最終的なデータマート層です。

主なモデル：

- `dim_patients`
- `dim_patient_progression`
- `fct_diagnosis_events`

ディメンションテーブルとファクトテーブルを分けることで、Lightdash などの BI ツールで扱いやすい構造にしています。

## Main Models

### `dim_patients`

患者・ユーザー単位の基本情報を持つディメンションモデルです。

想定される利用用途：

- ユーザー属性別の分析
- 登録ユーザー数の集計
- 利用者単位での問診状況の確認

### `fct_diagnosis_events`

問診票の回答・診断イベントを扱うファクトモデルです。

想定される利用用途：

- 問診件数の集計
- 日別・月別の利用推移
- 症状や回答内容の傾向分析
- ユーザーごとの診断履歴の分析

### `dim_patient_progression`

患者ごとの症状変化や利用状況を分析するためのディメンションモデルです。

想定される利用用途：

- 症状改善・悪化傾向の確認
- 継続利用者の分析
- 来院・回答サイクルの把握

## Lightdash Integration

本プロジェクトは Lightdash と連携し、dbt の metadata YAML をもとに BI 用の Explore を生成しています。

以下のように、Lightdash への deploy が正常に完了することを確認しています。

```bash
lightdash deploy
```

実行結果例：

```text
- SUCCESS> stg_users
- SUCCESS> stg_medical_diagnosis_form
- SUCCESS> int_medical_diagnoses_summary
- SUCCESS> dim_patients
- SUCCESS> int_medical_diagnoses_enriched
- SUCCESS> fct_diagnosis_events
- SUCCESS> dim_patient_progression
- SUCCESS> int_symptom_progression
- SUCCESS> int_patient_visit_cycles

Compiled 9 explores, SUCCESS=9 ERRORS=0
```

## Setup

### 1. Clone repository

```bash
git clone https://github.com/nosscafe66/my-duckdb-analytics.git
cd my-duckdb-analytics
```

### 2. Install dependencies

Python 環境を用意した上で、必要なパッケージをインストールします。

```bash
pip install dbt-core dbt-duckdb
```

Lightdash を利用する場合は、Lightdash CLI も準備します。

```bash
npm install -g @lightdash/cli
```

### 3. Check dbt connection

```bash
dbt debug
```

### 4. Run dbt models

```bash
dbt run
```

### 5. Run tests

```bash
dbt test
```

### 6. Generate dbt docs

```bash
dbt docs generate
dbt docs serve
```

### 7. Deploy to Lightdash

```bash
lightdash deploy
```

## Development Commands

よく使うコマンドは以下です。

```bash
# dbt の接続確認
dbt debug

# モデルの実行
dbt run

# 特定モデルのみ実行
dbt run --select stg_users

# テスト実行
dbt test

# ドキュメント生成
dbt docs generate

# dbt docs をローカルで確認
dbt docs serve

# Lightdash へデプロイ
lightdash deploy
```

## What I Learned

このプロジェクトを通じて、以下のようなデータエンジニアリングの実践経験を整理しています。

- アプリケーションデータを分析基盤へ変換する流れ
- dbt によるレイヤードアーキテクチャ設計
- staging / intermediate / marts の役割分担
- fact / dimension モデリング
- DuckDB を用いたローカルDWH構築
- Lightdash による BI / メトリクス管理
- YAML による metadata 管理
- 分析しやすいデータマート設計

## Future Improvements

今後は以下の改善を予定しています。

- dbt tests の追加
- schema.yml の description 充実
- Lightdash 上での metric 定義の拡充
- ダッシュボード作成
- BigQuery などクラウドDWHへの展開
- CI/CD による dbt run / test 自動化
- データ品質チェックの強化
- サンプルデータの整備

## Purpose

このリポジトリは、データエンジニアとしての以下のスキルを示すためのポートフォリオです。

- データ分析基盤の設計
- dbt によるデータ変換
- DWH / データマート設計
- BI ツールとの連携
- アプリケーションデータの分析活用
- データモデリング
- データエンジニアリングの学習・検証

## Author

Yuto Konosu

- GitHub: [nosscafe66](https://github.com/nosscafe66)
