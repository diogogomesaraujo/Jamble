import android.content.Intent;
import android.net.Uri;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "app_links";

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        Uri data = intent.getData();
        if (data != null) {
            new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
                .invokeMethod("getAppLink", data.toString());
        }
    }
}
