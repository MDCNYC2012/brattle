
package com.brattle;

import com.neurosky.thinkgear.TGDevice;

import org.xmlpull.v1.XmlPullParser;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.graphics.Color;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.Settings.Secure;
import android.util.Log;
import android.util.Xml;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

// http://108.12.134.59/RBT/mdevSendData.php?Unique_ID= &Attention= &Meditation= &Blink= &HeartRate= 

public class BrattleActivity extends Activity {
    BluetoothAdapter bluetoothAdapter;
    TextView status, meditation, attention, heartrate, blink, state;
    Button connectButton;
    TGDevice tgDevice;
    final boolean rawEnabled = false;
    String ID = "id";

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        status = (TextView) findViewById(R.id.status);
        state = (TextView) findViewById(R.id.state);
        state.setTextColor(Color.YELLOW);
        meditation = (TextView) findViewById(R.id.meditation);
        attention = (TextView) findViewById(R.id.attention);
        heartrate = (TextView) findViewById(R.id.heartrate);
        blink = (TextView) findViewById(R.id.blink);
        connectButton = (Button) findViewById(R.id.connect_button);
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (bluetoothAdapter == null) {
            Toast.makeText(this, "Bluetooth not available", Toast.LENGTH_LONG).show();
            finish();
            return;
        } else {
            /* create the TGDevice */
            tgDevice = new TGDevice(bluetoothAdapter, handler);
        }
        ID = Secure.getString(this.getContentResolver(), Secure.ANDROID_ID);
    }
    
    @Override
    public void onPause() {
        close();
        super.onDestroy();
    }    
    
    @Override
    public void onResume() {
        super.onRestart();
        state = (TextView) findViewById(R.id.state);
        state.setText("State: waiting");
    }
    
    private void close() {
        tgDevice.close();
        connectButton.setEnabled(true);
    }

    @Override
    public void onDestroy() {
        close();
        super.onDestroy();
    }

    /**
     * Handles messages from TGDevice
     */
    private final Handler handler = new Handler() {
        int attval=0, medval=0, blval=0, hrval=0;
        @Override
        public void handleMessage(Message msg) {
            boolean att=false, med=false, bl=false, hr=false;            
            switch (msg.what) {
                case TGDevice.MSG_STATE_CHANGE:
                    switch (msg.arg1) {
                        case TGDevice.STATE_IDLE:
                        break;
                    case TGDevice.STATE_CONNECTING:
                        status.setText("connecting...");
                        connectButton.setEnabled(false);
                        break;
                    case TGDevice.STATE_CONNECTED:
                        status.setText("connected");
                        tgDevice.start();         
                        connectButton.setEnabled(false);
                        break;
                    case TGDevice.STATE_NOT_FOUND:
                        status.setText("can't find");
                        connectButton.setEnabled(true);
                        break;
                    case TGDevice.STATE_NOT_PAIRED:
                        status.setText("not paired");
                        connectButton.setEnabled(true);
                        break;
                    case TGDevice.STATE_DISCONNECTED:
                        status.setText("disconnected");
                        connectButton.setEnabled(true);
                        blval=0;
                }
                break;
            case TGDevice.MSG_POOR_SIGNAL:
                    // signal = msg.arg1;
                    status.setText("Signal: %" + (200-msg.arg1)*100/200 );
                    break;
                case TGDevice.MSG_RAW_DATA:
                    // raw1 = msg.arg1;
                    // tv.append("Got raw: " + msg.arg1 + "\n");
                    break;
                case TGDevice.MSG_HEART_RATE:
                //heartrate.setText("HeartRate=" + msg.arg1);
                //hrval=msg.arg1;
                //hr = true;
                break;
            case TGDevice.MSG_ATTENTION:
                attention.setText("Attention: " + msg.arg1);
                attval=msg.arg1;
                att = true;
                break;
            case TGDevice.MSG_MEDITATION:
                meditation.setText("Meditation: " + msg.arg1);
                medval=msg.arg1;
                med = true;
                break;
            case TGDevice.MSG_BLINK:
                blink.setText("Blink: " + msg.arg1);
                blval=msg.arg1+blval;
                bl = true;
                break;
            case TGDevice.MSG_RAW_COUNT:
                // tv.append("Raw Count: " + msg.arg1 + "\n");
                break;
            case TGDevice.MSG_LOW_BATTERY:
                Toast.makeText(getApplicationContext(), "Low battery!", Toast.LENGTH_SHORT).show();
                break;
            case TGDevice.MSG_RAW_MULTI:
                // TGRawMulti rawM = (TGRawMulti)msg.obj;
                // tv.append("Raw1: " + rawM.ch1 + "\nRaw2: " + rawM.ch2);
            default:
                break;
        }
        if(bl||med||att) {
            (new AsyncTask<Integer, String, Void>() {
                String result = "stop";
                @Override
                protected Void doInBackground(Integer... params) {
                    result=send(params[0], params[1], params[2], params[3]);
               //     onProgressUpdate(result);
                    return null;
                }
                @Override
                protected void onProgressUpdate(String... result) {
                    if(result.equals("started")) {
                        updateState("State: START!", Color.GREEN);
                    } else if(result.equals("done")) {
                        updateState("State: DONE!", Color.BLUE);
                    } else {
                        updateState("State: "+result, Color.RED);
                    }                    
                }
                }).execute(attval, medval, blval, hrval);
            }
        }
        
        private void updateState(String update, int color) {
            state.setText("update");
            state.setTextColor(color);
        }

        private String send(int attval, int medval, int blval, int hrval) {

            final String urlstr = "http://108.12.134.59/RBT/mdevSendData.php/?unique_ID="+ID+"&attention="+attval+"&meditation="+medval+"&blink="+blval+"&heartRate="+hrval;
            
            Log.w("BRATTLE",urlstr);
            String result="stop";
            
            try {
                final URL url = new URL(urlstr);
                final HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
                try {
                    final BufferedReader reader = new BufferedReader(new InputStreamReader(urlConnection.getInputStream()));
                    
                    XmlPullParser parser = Xml.newPullParser();
                    parser.setInput(reader);

                    parser.nextTag();
                    parser.require(XmlPullParser.START_TAG, null, "root");
                    while (parser.nextTag() == XmlPullParser.START_TAG) {
                        parser.require(XmlPullParser.START_TAG, null, "state");
                        result = parser.nextText();
                        if (parser.getEventType() != XmlPullParser.END_TAG) {
                            parser.nextTag();
                        }
                        parser.require(XmlPullParser.END_TAG, null, "state");
                    }
                    parser.require(XmlPullParser.END_TAG, null, "root");
                } catch(Exception e) {
                    Log.e("BRATTLE",e.getMessage());
                } finally {
                    urlConnection.disconnect();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            return result;
        }
    };

    public void doConnect(View view) {
        if (tgDevice.getState() != TGDevice.STATE_CONNECTING
                && tgDevice.getState() != TGDevice.STATE_CONNECTED) {
            tgDevice.connect(rawEnabled);
        } else {
            tgDevice.close();
            
        }
    }
}
