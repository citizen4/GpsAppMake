package kc87.gpsapp.view;

import android.content.Context;
import android.graphics.Color;
import android.util.AttributeSet;
import android.widget.LinearLayout;
import android.widget.TextView;

import kc87.gpsapp.R;
import kc87.gpsapp.presenter.GpsPresenter;

import java.util.ArrayList;
import java.util.List;

public class GpsView extends LinearLayout {
   private static final String LOG_TAG = "GpsView";
   private GpsPresenter mPresenter;
   private List<TextView> mValueViewList;

   private TextView mSatsValueView;
   private TextView mTimeValueView;
   private TextView mLatValueView;
   private TextView mLngValueView;
   private TextView mAltValueView;
   private TextView mSpeedValueView;
   private TextView mCourseValueView;


   public GpsView(Context context, AttributeSet attrs) {
      super(context, attrs);
   }

   public GpsPresenter getPresenter() {
      return mPresenter;
   }

   @Override
   protected void onFinishInflate() {
      super.onFinishInflate();
      setup();
   }

   public void updateGpsView(final GpsViewData gpsDataSet) {
      mSatsValueView.setText(gpsDataSet.satellites);
      mTimeValueView.setText(gpsDataSet.utcTime);
      mLatValueView.setText(gpsDataSet.latitude);
      mLngValueView.setText(gpsDataSet.longitude);
      mAltValueView.setText(gpsDataSet.altitude);
      mSpeedValueView.setText(gpsDataSet.speedKmh);
      mCourseValueView.setText(gpsDataSet.course);

      for (TextView valueView : mValueViewList) {
         valueView.setTextColor(gpsDataSet.hasFix ? Color.GREEN : Color.DKGRAY);
      }
   }

   private void setup() {
      mValueViewList = new ArrayList<>();

      mSatsValueView = (TextView) findViewById(R.id.sats_value);
      mTimeValueView = (TextView) findViewById(R.id.time_value);
      mLatValueView = (TextView) findViewById(R.id.lat_value);
      mLngValueView = (TextView) findViewById(R.id.lng_value);
      mAltValueView = (TextView) findViewById(R.id.alt_value);
      mSpeedValueView = (TextView) findViewById(R.id.speed_value);
      mCourseValueView = (TextView) findViewById(R.id.course_value);

      mValueViewList.add(mSatsValueView);
      mValueViewList.add(mTimeValueView);
      mValueViewList.add(mLatValueView);
      mValueViewList.add(mLngValueView);
      mValueViewList.add(mAltValueView);
      mValueViewList.add(mSpeedValueView);
      mValueViewList.add(mCourseValueView);

      mPresenter = new GpsPresenter(this);
   }

}
