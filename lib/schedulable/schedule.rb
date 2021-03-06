require 'will_paginate/active_record'
module Schedulable
  module Model
    class Schedule  < ActiveRecord::Base

      serialize :minute_of_hour
      serialize :hour_of_day
      serialize :day
      serialize :day_of_week, Hash
      serialize :day_of_month

      belongs_to :schedulable, polymorphic: true

      after_initialize :update_schedule
      before_save :update_schedule

      validates_presence_of :rule
      validates_presence_of :time
      validates_presence_of :date, if: Proc.new { |schedule| schedule.rule == 'singular' }
      validate :validate_day, if: Proc.new { |schedule| schedule.rule == 'weekly' }
      validate :validate_day_of_week, if: Proc.new { |schedule| schedule.rule == 'monthly' && schedule.day_of_month.blank? }
      validate :validate_day_of_month, if: Proc.new { |schedule| schedule.rule == 'monthly' && schedule.day_of_week.blank? }

      def to_icecube
        return @schedule
      end

      def to_s
        message = ""
        if self.rule == 'singular'
          # Return formatted datetime for singular rules
          datetime = DateTime.new(date.year, date.month, date.day, time.hour, time.min, time.sec, time.zone)
          message = ::I18n.localize(datetime)
        else
          # For other rules, refer to icecube
          begin
            message = @schedule.to_s
          rescue Exception
            locale = I18n.locale
            ::I18n.locale = :en
            message = @schedule.to_s
            ::I18n.locale = locale
          end
        end
        return message
      end

      def method_missing(meth, *args, &block)
        if @schedule.present? && @schedule.respond_to?(meth)
          @schedule.send(meth, *args, &block)
        end
      end

      def self.param_names
        [:id, :date, :time, :rule, :until, :count, :interval, day: [], day_of_week: [monday: [], tuesday: [], wednesday: [], thursday: [], friday: [], saturday: [], sunday: []]]
      end

      def update_schedule()

        self.rule||= "singular"
        self.interval||= 1
        self.count||= 0

        time = Date.today.to_time(:utc)
        if self.time.present?
          time = time + self.time.seconds_since_midnight.seconds
        end
        time_string = time.strftime("%d-%m-%Y %I:%M %p")
        time = Time.zone.parse(time_string)

        @schedule = IceCube::Schedule.new(time)

        if self.rule && self.rule != 'singular'

          self.interval = self.interval.present? ? self.interval.to_i : 1

          rule = IceCube::Rule.send("#{self.rule}", self.interval)
          rule.until(self.until) if self.until
          rule.count(self.count.to_i) if self.count.to_i > 0

          # mins and hours
          rule.minute_of_hour(minute_of_hour.to_i) if minute_of_hour.present?
          rule.hour_of_day(hour_of_day.to_i) if hour_of_day.present?

          days = self.day.reject(&:empty?) if self.day
          if self.rule == 'weekly'
            days.each do |day|
              rule.day(day.to_sym)
            end
          elsif self.rule == 'monthly'
            rule.day_of_week(day_of_week) if day_of_week.present?
            rule.day_of_month(day_of_month.map{ |x| x.to_i}) if day_of_month.present?
          elsif self.rule == 'yearly'
            rule.day_of_week(day_of_week) if day_of_week.present?
            rule.day_of_month(day_of_month.map{ |x| x.to_i}) if day_of_month.present?
            if month_of_year.present?
              rule.month_of_year(month_of_year.split(',').map{ |x| x.to_i}) if month_of_year.is_a?(String)
              rule.month_of_year(month_of_year.map{ |x| x.to_i}) if month_of_year.is_a?(Array)
              rule.month_of_year([month_of_year]) if month_of_year.is_a?(Integer)
            end
          end
          @schedule.add_recurrence_rule(rule)
        end

      end

      private

      def validate_day
        day.reject! { |c| c.empty? }
        if !day.any?
          errors.add(:day, :empty)
        end
      end

      def validate_day_of_week
        any = false
        day_of_week.each { |key, value|
          value.reject! { |c| c.to_s.empty? }
          if value.length > 0
            any = true
            break
          end
        }
        if !any
          errors.add(:day_of_week, :empty)
        end
      end
    end
  end
end