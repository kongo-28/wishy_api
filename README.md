# テーブル設計

## users テーブル

| Column             | Type   | Options                  |
| :----------------- | :----- | :----------------------- |
| email              | string | null:false, unique: true |
| encrypted_password | string | null:false               |

### Association

- has_many :likes

## wishes テーブル

| Column  | Type   | Options    |
| :------ | :----- | :--------- |
| title   | string | null:false |
| content | string |            |

### Association

- has_many :likes

## likes テーブル

| Column | Type       | Options                       |
| :----- | :--------- | :---------------------------- |
| count  | integer    | null:false                    |
| wish   | references | null:false, foreign_key: true |
| user   | references | null:false, foreign_key: true |

### Association

- belongs_to :user
- belongs_to :wish
