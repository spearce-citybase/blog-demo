class CreatePostMetrics < ActiveRecord::Migration[7.1]
  def change
    create_table :post_metrics do |t|
      t.references :post, index: { unique: true }
      t.integer :views
      t.timestamps
    end
  end
end
